import Perception
import UIKit

extension NSObject {
    
    func observe(_ apply: @escaping () -> Void) {
        withPerceptionTracking {
            apply()
        } onChange: {
            Task { @MainActor in
                self.observe(apply)
            }
        }
    }
}
