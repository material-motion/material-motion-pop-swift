/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import ReactiveMotion
import pop

// In order to support POP's vector-based properties we create specialized connectPOPSpring methods.
// Each specialized method is expected to read from and write to a POP vector value.

/**
 Create a motion observable that will emit T values on the main thread simulating the provided
 spring parameters.
 */
public func pop<T>(_ spring: SpringShadow<T>) -> (MotionObservable<T>) {
  return MotionObservable("POP spring", args: [spring.enabled, spring.state, spring.initialValue, spring.initialVelocity, spring.destination, spring.tension, spring.friction, spring.mass, spring.suggestedDuration, spring.threshold]) { observer in
    let popProperty = POPMutableAnimatableProperty()
    popProperty.threshold = spring.threshold.value

    if let observer = observer as? MotionObserver<CGPoint> {
      popProperty.readBlock = { _, toWrite in
        let value = spring.initialValue.value as! CGPoint
        toWrite![0] = value.x
        toWrite![1] = value.y
      }
      popProperty.writeBlock = { _, toRead in
        observer.next(CGPoint(x: toRead![0], y: toRead![1]))
      }
    } else if let observer = observer as? MotionObserver<CGFloat> {
      popProperty.readBlock = { _, toWrite in
        toWrite![0] = spring.initialValue.value as! CGFloat
      }
      popProperty.writeBlock = { _, toRead in
        observer.next(toRead![0])
      }
    } else {
      assertionFailure("Unsupported type")
    }

    return configureSpringAnimation(popProperty, spring: spring)
  }
}

private func configureSpringAnimation<T>(_ property: POPAnimatableProperty, spring: SpringShadow<T>) -> () -> Void {
  var destination: T?

  let createAnimation: () -> POPSpringAnimation = {
    let animation = POPSpringAnimation()

    animation.property = property
    animation.dynamicsFriction = spring.friction.value
    animation.dynamicsTension = spring.tension.value
    animation.velocity = spring.initialVelocity.value

    animation.toValue = destination
    animation.removedOnCompletion = false

    animation.animationDidStartBlock = { anim in
      spring.state.value = .active
    }
    animation.completionBlock = { anim, finished in
      spring.state.value = .atRest
    }
    return animation
  }

  var animation: POPSpringAnimation?

  let destinationSubscription = spring.destination.subscribeToValue { value in
    destination = value
    animation?.toValue = destination
    animation?.isPaused = false
  }

  let key = NSUUID().uuidString
  let someObject = NSObject()

  let activeSubscription = spring.enabled.dedupe().subscribeToValue { enabled in
    if enabled {
      if animation == nil {
        animation = createAnimation()

        // animationDidStartBlock is invoked at the turn of the run loop, potentially leaving this stream
        // in an at rest state even though it's effectively active. To ensure that the stream is marked
        // active until the run loop turns we immediately send an .active state to the observer.

        spring.state.value = .active

        someObject.pop_add(animation, forKey: key)
      }

    } else {
      if animation != nil {
        animation = nil
        someObject.pop_removeAnimation(forKey: key)
      }
    }
  }

  return {
    someObject.pop_removeAnimation(forKey: key)
    destinationSubscription.unsubscribe()
    activeSubscription.unsubscribe()
  }
}
