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
import ReactiveMotionPOP

public class TossableExampleViewController: UIViewController {

  var runtime: MotionRuntime!
  public override func viewDidLoad() {
    super.viewDidLoad()

    runtime = MotionRuntime(containerView: view)

    view.backgroundColor = .white

    var center = view.center
    center.x -= 32
    center.y -= 32

    let square2 = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    square2.backgroundColor = .orange
    view.addSubview(square2)

    let circle = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    circle.backgroundColor = .blue
    circle.layer.cornerRadius = circle.bounds.width / 2
    view.addSubview(circle)

    let square = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    square.backgroundColor = .red
    view.addSubview(square)

    let gesture = UIPanGestureRecognizer()
    view.addGestureRecognizer(gesture)
    let draggable = Draggable(.withExistingRecognizer(gesture))
    let tossable = Tossable(system: pop, draggable: draggable)
    let target = runtime.get(circle).reactiveLayer.position
    runtime.connect(target, to: tossable.spring.destination)
    runtime.add(tossable, to: square)
    runtime.add(SetPositionOnTap(coordinateSpace: view), to: target)

    let spring = Spring<CGPoint>(threshold: 1, system: coreAnimation)
    runtime.connect(tossable.spring.destination, to: spring.destination)
    runtime.add(spring, to: runtime.get(square2.layer).position)
  }
}
