//
//  ClockSelectionViewController.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 5.03.2024.
//

import UIKit
import Foundation

class ClockSelectionViewController: UIViewController {

    let hourCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 150
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.isUserInteractionEnabled = true
        return view
    }()

    let minuteCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 150
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.isUserInteractionEnabled = true
        return view
    }()

    var selectedHour: Int = 12
    var selectedMinute: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(hourCircle)
        view.addSubview(minuteCircle)

        hourCircle.frame = CGRect(x: 50, y: 100, width: 300, height: 300)
        minuteCircle.frame = CGRect(x: 450, y: 100, width: 300, height: 300)

        addPanGesture(to: hourCircle, selector: #selector(handleHourPan(_:)))
        addPanGesture(to: minuteCircle, selector: #selector(handleMinutePan(_:)))
    }

    func addPanGesture(to view: UIView, selector: Selector) {
        let panGesture = UIPanGestureRecognizer(target: self, action: selector)
        view.addGestureRecognizer(panGesture)
    }

    @objc func handleHourPan(_ sender: UIPanGestureRecognizer) {
        handlePan(sender, circleView: hourCircle, unit: 12, selector: #selector(updateHourLabel))
    }

    @objc func handleMinutePan(_ sender: UIPanGestureRecognizer) {
        handlePan(sender, circleView: minuteCircle, unit: 60, selector: #selector(updateMinuteLabel))
    }

    func handlePan(_ sender: UIPanGestureRecognizer, circleView: UIView, unit: Int, selector: Selector) {
        let translation = sender.translation(in: view)
        let angle = atan2(translation.y, translation.x)
        let angleInDegrees = angle * (180.0 / .pi)
        let normalizedAngle = angleInDegrees < 0 ? angleInDegrees + 360 : angleInDegrees
        let segmentAngle = 360.0 / Double(unit)
        let selectedSegment = Int(round(normalizedAngle / segmentAngle))
        let radians = Double(selectedSegment) * segmentAngle * (.pi / 180.0)

        let rotation = CGAffineTransform(rotationAngle: CGFloat(radians))
        circleView.transform = rotation

        perform(Selector(selector))
    }

    @objc func updateHourLabel() {
        selectedHour = Int(hourCircle.transform.rotated(by: -CGFloat.pi / 2).a / hourCircle.transform.a) % 12 + 1
        print("Selected Hour: \(selectedHour)")
    }

    @objc func updateMinuteLabel() {
        selectedMinute = Int(minuteCircle.transform.rotated(by: -CGFloat.pi / 2).a / minuteCircle.transform.a) % 60
        print("Selected Minute: \(selectedMinute)")
    }
}
