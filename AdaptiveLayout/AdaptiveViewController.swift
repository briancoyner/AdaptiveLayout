//
//  Created by Brian Coyner on 7/8/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation
import UIKit
import MapKit

final class AdaptiveViewController: UIViewController {

    fileprivate lazy var mapView = self.lazyMapView()
    fileprivate lazy var actionsToolbar = self.lazyActionsToolbar()
    fileprivate lazy var actionsViewController = self.lazyActionsViewController()
}

extension AdaptiveViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Adaptive View Controller"

        view.addSubview(mapView)
        view.addSubview(actionsToolbar)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            actionsToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            actionsToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionsToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        addChild(actionsViewController)
        let actionsBarItem = UIBarButtonItem(customView: actionsViewController.view)
        actionsViewController.didMove(toParent: self)

        actionsToolbar.items = [
            UIBarButtonItem(title: "Calc", style: .plain, target: self, action: #selector(userWantsToCalculateDistance)),
            .flexibleSpace,
            actionsBarItem,
            .flexibleSpace,
            UIBarButtonItem(title: "Dummy", style: .plain, target: nil, action: nil)
        ]
    }
}

extension AdaptiveViewController {
    
    @objc
    fileprivate func userWantsToCalculateDistance() {
        let leadingPointA = mapView.convert(CGPoint(x: 0, y: 0), toCoordinateFrom: mapView)
        let trailingPointB = mapView.convert(CGPoint(x: 0, y: mapView.bounds.height), toCoordinateFrom: mapView)
        let pointA = MKMapPoint(leadingPointA)
        let pointB = MKMapPoint(trailingPointB)
        
        let distance = pointB.distance(to: pointA)
        let meters = Measurement(value: distance, unit: UnitLength.meters)

        print("Distance: \(meters.converted(to: .miles))")
    }
}

extension AdaptiveViewController: UIToolbarDelegate {

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }
}

extension AdaptiveViewController {

    fileprivate func lazyMapView() -> MKMapView {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false

        mapView.mapType = .hybrid

        return mapView
    }

    fileprivate func lazyActionsToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        toolbar.delegate = self

        return toolbar
    }

    fileprivate func lazyActionsViewController() -> AdaptiveActionsViewController {
        return AdaptiveActionsViewController(actions: makeDummyAdaptiveActions())
    }
}

extension AdaptiveViewController {

    fileprivate func makeDummyAdaptiveActions() -> [AdaptiveAction] {
        return [
            AdaptiveAction(title: "Magic Kingdom", action: {
                self.zoomMap(to: CLLocationCoordinate2D(latitude: 28.418674, longitude: -81.581190))
            }),
            AdaptiveAction(title: "Epcot", action: {
                self.zoomMap(to: CLLocationCoordinate2D(latitude: 28.374127, longitude: -81.549368))
            }),
            AdaptiveAction(title: "Animal Kingdom", action: {
                self.zoomMap(to: CLLocationCoordinate2D(latitude: 28.355167, longitude: -81.590095))
            })
        ]
    }

    fileprivate func zoomMap(to location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudeDelta: Measurement(value: 1, unit: .miles))
        mapView.setRegion(region, animated: true)
    }
}
