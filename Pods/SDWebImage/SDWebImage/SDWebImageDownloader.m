/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloader.h"
#import "SDWebImageDownloaderConfig.h"
#import "SDWebImageDownloaderOperation.h"
#import "SDWebImageError.h"

static void * SDWebImageDownloaderContext = &SDWebImageDownloaderContext;

@interface SDWebImageDownloadToken ()

@property (nonatomic, strong, nullable, readwrite) NSURL *url;
@property (nonatomic, strong, nullable, readwrite) NSURLRequest *request;
@property (nonatomic, strong, nullable, readwrite) NSURLResponse *response;
@property (nonatomic, strong, nullable, readwrite) id downloadOperationCancelToken;
@property (nonatomic, weak, nullable) NSOperation<SDWebImageDownloaderOperation> *downloadOperation;
@property (nonatomic, weak, nullable) SDWebImageDownloader *downloader;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

@end

@interface SDWebImageDownloader () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic, nonnull) NSOperationQueue *downloadQueue;
@property (weak, nonatomic, nullable) NSOperation *lastAddedOperation;
@property (strong, nonatomic, nonnull) NSMutableDictionary<NSURL *, NSOperation<SDWebImageDownloaderOperation> *> *URLOperations;
@property (copy, atomic, nullable) NSDictionary<NSString *, NSString *> *HTTPHeaders; // Since modify this value is rare, use immutable object can enhance performance. But should mark as atomic to keep thread-safe
@property (strong, nonatomic, nonnull) dispatch_semaphore_t operationsLock; // a lock to keep the access to `URLOperations` thread-safe

// The session in which data tasks will run
@property (strong, nonatomic) NSURLSession *session;

@end

@implementation SDWebImageDownloader

+ (void)initialize {
    // Bind SDNetworkActivityIndicator if available (download it here: http://github.com/rs/SDNetworkActivityIndicator )
    // To use it, just add #import "SDNetworkActivityIndicator.h" in addition to the SDWebImage import
    if (NSClassFromString(@"SDNetworkActivityIndicator")) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id activityIndicator = [NSClassFromString(@"SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
#pragma clang diagnostic pop

        // Remove observer in case it was previously added.
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:SDWebImageDownloadStopNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"startActivity")
                                                     name:SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"stopActivity")
                                                     name:SDWebImageDownloadStopNotification object:nil];
    }
}

+ (nonnull instancetype)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    return [self initWithConfig:SDWebImageDownloaderConfig.defaultDownloaderConfig];
}

- (instancetype)initWithConfig:(SDWebImageDownloaderConfig *)config {
    self = [super init];
    if (self) {
        if (!config) {
            config = SDWebImageDownloaderConfig.defaultDownloaderConfig;
        }
        _config = [config copy];
        [_config addObserver:self forKeyPath:NSStringFromSelector(@selector(maxConcurrentDownloads)) options:0 context:SDWebImageDownloaderContext];
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = _config.maxConcurrentDownloads;
        _downloadQueue.name = @"com.hackemist.SDWebImageDownloader";
        _URLOperations = [NSMutableDictionary new];
#ifdef SD_WEBP
        _HTTPHeaders = @{@"Accept": @"image/webp,image/*;q=0.8"};
#else
        _HTTPHeaders = @{@"Accept": @"image/*;q=0.8"};
#endif
        _operationsLock = dispatch_semaphore_create(1);
        NSURLSessionConfiguration *sessionConfiguration = _config.sessionConfiguration;
        if (!sessionConfiguration) {
            sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        /**
         *  Create the session for this task
         *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
         *  method calls and completion handler calls.
         */
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    }
    return self;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
    
    [self.downloadQueue cancelAllOperations];
    [self.config removeObserver:self forKeyPath:NSStringFromSelector(@selector(maxConcurrentDownloads)) context:SDWebImageDownloaderContext];
}

- (void)invalidateSessionAndCancel:(BOOL)cancelPendingOperations {
    if (self == [SDWebImageDownloader sharedDownloader]) {
        return;
    }
    if (cancelPendingOperations) {
        [self.session invalidateAndCancel];
    } else {
        [self.session finishTasksAndInvalidate];
    }
}

- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(nullable NSString *)field {
    if (!field) {
        return;
    }
    NSMutableDictionary *mutableHTTPHeaders = [self.HTTPHeaders mutableCopy];
    if (value) {
        [mutableHTTPHeaders setObject:value forKey:field];
    } else {
        [mutableHTTPHeaders removeObjectForKey:field];
    }
    self.HTTPHeaders = [mutableHTTPHeaders copy];
}

- (nullable NSString *)valueForHTTPHeaderField:(nullable NSString *)field {
    if (!field) {
        return nil;
    }
    return [self.HTTPHeaders objectForKey:field];
}

- (nullable SDWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url options:(SDWebImageDownloaderOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageDownloaderCompletedBlock)completedBlock {
    return [self downloadImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

- (nullable SDWebImageDownloadToken *)downloadImageWithURL:(nullable NSURL *)url
                                                   options:(SDWebImageDownloaderOptions)options
                                                   context:(nullable SDWebImageContext *)context
                                                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                                                 completed:(nullable SDWebImageDownloaderCompletedBlock)completedBlock {
    __weak SDWebImageDownloader *wself = self;

    return [self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^NSOperation<SDWebImageDownloaderOperation> *{
        __strong __typeof (wself) sself = wself;
        NSTimeInterval timeoutInterval = sself.config.downloadTimeout;
        if (timeoutInterval == 0.0) {
            timeoutInterval = 15.0;
        }

        // In order to prevent from potential duplicate caching (NSURLCache + SDImageCache) we disable the cache for image requests if told otherwise
        NSURLRequestCachePolicy cachePolicy = options & SDWebImageDownloaderUseNSURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData;
        NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
        mutableRequest.HTTPShouldHandleCookies = (options & SDWebImageDownloaderHandleCookies);
        mutableRequest.HTTPShouldUsePipelining = YES;
        mutableRequest.allHTTPHeaderFields = sself.HTTPHeaders;
        id<SDWebImageDownloaderRequestModifier> requestModifier;
        if ([context valueForKey:SDWebImageContextDownloadRequestModifier]) {
            requestModifier = [context valueForKey:SDWebImageContextDownloadRequestModifier];
        } else {
            requestModifier = self.requestModifier;
        }
        
        NSURLRequest *request;
        if (requestModifier) {
            NSURLRequest *modifiedRequest = [requestModifier modifiedRequestWithRequest:[mutableRequest copy]];
            // If modified request is nil, early return
            if (!modifiedRequest) {
                return nil;
            } else {
                request = [modifiedRequest copy];
            }
        } else {
            request = [mutableRequest copy];
        }
        Class operationClass = sself.config.operationClass;
        if (operationClass && [operationClass isSubclassOfClass:[NSOperation class]] && [operationClass conformsToProtocol:@protocol(SDWebImageDownloaderOperation)]) {
            // Custom operation class
        } else {
            operationClass = [SDWebImageDownloaderOperation class];
        }
        NSOperation<SDWebImageDownloaderOperation> *operation = [[operationClass alloc] initWithRequest:request inSession:sself.session options:options context:context];
        
        if (sself.config.urlCredential) {
            operation.credential = sself.config.urlCredential;
        } else if (sself.config.username && sself.config.password) {
            operation.credential = [NSURLCredential credentialWithUser:sself.config.username password:sself.config.password persistence:NSURLCredentialPersistenceForSession];
        }
        
        if (options & SDWebImageDownloaderHighPriority) {
            operation.queuePriority = NSOperationQueuePriorityHigh;
        } else if (options & SDWebImageDownloaderLowPriority) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        }
        
        if (sself.config.executionOrder == SDWebImageDownloaderLIFOExecutionOrder) {
            // Emulate LIFO execution order by systematically adding new operations as last operation's dependency
            [sself.lastAddedOperation addDependency:operation];
            sself.lastAddedOperation = operation;
        }

        return operation;
    }];
}

- (void)cancel:(nullable SDWebImageDownloadToken *)token {
    NSURL *url = token.url;
    if (!url) {
        return;
    }
    LOCK(self.operationsLock);
    NSOperation<SDWebImageDownloaderOperation> *operation = [self.URLOperations objectForKey:url];
    if (operation) {
        BOOL canceled = [operation cancel:token.downloadOperationCancelToken];
        if (canceled) {
            [self.URLOperations removeObjectForKey:url];
        }
    }
    UNLOCK(self.operationsLock);
}

- (nullable SDWebImageDownloadToken *)addProgressCallback:(SDWebImageDownloaderProgressBlock)progressBlock
                                           completedBlock:(SDWebImageDownloaderCompletedBlock)completedBlock
                                                   forURL:(nullable NSURL *)url
                                           createCallback:(NSOperation<SDWebImageDownloaderOperation> *(^)(void))createCallback {
    // The URL will be used as the key to the callbacks dictionary so it cannot be nil. If it is nil immediately call the completed block with no image or data.
    if (url == nil) {
        if (completedBlock) {
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}];
            completedBlock(nil, nil, error, YES);
        }
        return nil;
    }
    
    LOCK(self.operationsLock);
    NSOperation<SDWebImageDownloaderOperation> *operation = [self.URLOperations objectForKey:url];
    if (!operation || operation.isFinished) {
    // There is a case that the operation may be marked as finished, but not been removed from `self.URLOperations`.
        operation = createCallback();
        if (!operation) {
            UNLOCK(self.operationsLock);
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorInvalidDownloadOperation userInfo:@{NSLocalizedDescriptionKey : @"Downloader operation is nil"}];
                completedBlock(nil, nil, error, YES);
            }
            return nil;
        }
        __weak typeof(self) wself = self;
        operation.completionBlock = ^{
            __strong typeof(wself) sself = wself;
            if (!sself) {
                return;
            }
            LOCK(sself.operationsLock);
            [sself.URLOperations removeObjectForKey:url];
            UNLOCK(sself.operationsLock);
        };
        [self.URLOperations setObject:operation forKey:url];
        // Add operation to operation queue only after all configuration done according to Apple's doc.
        // `addOperation:` does not synchronously execute the `operation.completionBlock` so this will not cause deadlock.
        [self.downloadQueue addOperation:operation];
    }
    UNLOCK(self.operationsLock);

    id downloadOperationCancelToken = [operation addHandlersForProgress:progressBlock completed:completedBlock];
    
    SDWebImageDownloadToken *token = [SDWebImageDownloadToken new];
    token.downloadOperation = operation;
    token.url = url;
    token.request = operation.request;
    token.downloadOperationCancelToken = downloadOperationCancelToken;
    token.downloader = self;

    return token;
}

- (void)cancelAllDownloads {
    [self.downloadQueue cancelAllOperations];
}

#pragma mark - Properties

- (BOOL)isSuspended {
    return self.downloadQueue.isSuspended;
}

- (void)setSuspended:(BOOL)suspended {
    self.downloadQueue.suspended = suspended;
}

- (NSUInteger)currentDownloadCount {
    return self.downloadQueue.operationCount;
}

- (NSURLSessionConfiguration *)sessionConfiguration {
    return self.session.configuration;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == SDWebImageDownloaderContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(maxConcurrentDownloads))]) {
            self.downloadQueue.maxConcurrentOperationCount = self.config.maxConcurrentDownloads;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Helper methods

- (NSOperation<SDWebImageDownloaderOperation> *)operationWithTask:(NSURLSessionTask *)task {
    NSOperation<SDWebImageDownloaderOperation> *returnOperation = nil;
    for (NSOperation<SDWebImageDownloaderOperation> *operation in self.downloadQueue.operations) {
        if ([operation respondsToSelector:@selector(dataTask)]) {
            if (operation.dataTask.taskIdentifier == task.taskIdentifier) {
                returnOperation = operation;
                break;
            }
        }
    }
    return returnOperation;
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperation> *dataOperation = [self operationWithTask:dataTask];
    if ([dataOperation respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        [dataOperation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(NSURLSessionResponseAllow);
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperation> *dataOperation = [self operationWithTask:dataTask];
    if ([dataOperation respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [dataOperation URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperation> *dataOperation = [self operationWithTask:dataTask];
    if ([dataOperation respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
        [dataOperation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(proposedResponse);
        }
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperation> *dataOperation = [self operationWithTask:task];
    if ([dataOperation respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [dataOperation URLSession:session task:task didCompleteWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperation> *dataOperation = [self operationWithTask:task];
    if ([dataOperation respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)]) {
        [dataOperation URLSession:session task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(request);
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperation> *dataOperation = [self operationWithTask:task];
    if ([dataOperation respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
        [dataOperation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    }
}

@end

@implementation SDWebImageDownloadToken

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SDWebImageDownloadReceiveResponseNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadReceiveResponse:) name:SDWebImageDownloadReceiveResponseNotification object:nil];
    }
    return self;
}

- (void)downloadReceiveResponse:(NSNotification *)notification {
    NSOperation<SDWebImageDownloaderOperation> *downloadOperation = notification.object;
    if (downloadOperation && downloadOperation == self.downloadOperation) {
        self.response = downloadOperation.response;
    }
}

- (void)cancel {
    @synchronized (self) {
        if (self.isCancelled) {
            return;
        }
        self.cancelled = YES;
        if (self.downloader) {
            // Downloader is alive, cancel token
            [self.downloader cancel:self];
        } else {
            // Downloader is dealloced, only cancel download operation
            [self.downloadOperation cancel:self.downloadOperationCancelToken];
        }
        self.downloadOperationCancelToken = nil;
    }
}

@end

@implementation SDWebImageDownloader (SDImageLoader)

- (BOOL)canLoadWithURL:(NSURL *)url {
    if (!url) {
        return NO;
    }
    // Always pass YES to let URLSession or custom download operation to determine
    return YES;
}

- (id<SDWebImageOperation>)loadImageWithURL:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDImageLoaderCompletedBlock)completedBlock {
    UIImage *cachedImage;
    if ([context valueForKey:SDWebImageContextLoaderCachedImage]) {
        cachedImage = [context valueForKey:SDWebImageContextLoaderCachedImage];
    }
    SDWebImageDownloaderOptions downloaderOptions = 0;
    if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;
    if (options & SDWebImageProgressiveLoad) downloaderOptions |= SDWebImageDownloaderProgressiveLoad;
    if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
    if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
    if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
    if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
    if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
    if (options & SDWebImageScaleDownLargeImages) downloaderOptions |= SDWebImageDownloaderScaleDownLargeImages;
    
    if (cachedImage && options & SDWebImageRefreshCached) {
        // force progressive off if image already cached but forced refreshing
        downloaderOptions &= ~SDWebImageDownloaderProgressiveLoad;
        // ignore image read from NSURLCache if image if cached but force refreshing
        downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
    }
    
    return [self downloadImageWithURL:url options:downloaderOptions context:context progress:progressBlock completed:completedBlock];
}

@end
