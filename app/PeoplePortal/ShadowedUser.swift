import UIKit

class User {
    var userId : Int
    var screenName : String
    var imageUrl : String
    var cachedImage : UIImage?

    func init(userId : Int, screenName : String, imageUrl : String) {
        self.userId = userId
        self.screenName = screenName
        self.imageUrl = imageUrl
    }

    func getImage(callback : (UIImage) -> ()) {
        if cachedImage != nil {
            callback(cachedImage)
        } else {
                        
        }
    }
}

class ShadowedUser {
    var following : Array<Int> = []
    var followers : Array<Int> = []
        
    func change(newUserId : Int) {
        
    }
    
    func save() {        
        
    }

    func addChange() {
        
    }
}
