import RxSwift

Observable<String>
    .just("Hello, World!")
    .subscribe(onNext: {
        print($0)
    })
