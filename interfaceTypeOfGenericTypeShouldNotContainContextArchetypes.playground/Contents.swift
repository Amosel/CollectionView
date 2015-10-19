import UIKit

//protocol MyProtocol{
//    init()
//}
//
//class MyClass <M:MyProtocol> {
//    typealias MyConcreteProtocolType = M
//    var myVar = MyConcreteProtocolType() {
//        didSet {
//            print("very happy")
//        }
//    }
//}
//
//struct MyProtocolImpl : MyProtocol {
//    init() {
//        print("init")
//    }
//}
//
//typealias MyConcreteClass = MyClass<MyProtocolImpl>
//
//let object = MyConcreteClass()
//let myOtherProtocolImpl = MyProtocolImpl()
//object.myVar = myOtherProtocolImpl
//print("happy")

protocol CollectionViewLayoutMetrics {
    var sectionMargin:CGFloat { get }
    var nodeSize:CGSize { get }
    var sectionPadding:CGFloat { get }
    init()
}

class CollectionViewLayout <M:CollectionViewLayoutMetrics> : UICollectionViewLayout {
    typealias Metrics = M
    override init() {
        super.init()
    }
    
    var metrics = Metrics()
        {
        didSet {
            self.invalidateLayout()
        }
    }
}


print("happy")
