//
//  Created by Brian Coyner on 7/9/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation
import MapKit

extension MKCoordinateRegion {

    private enum Constants {
        /// According to the docs for `MKCoordinateRegion`, the `latitudeDelta` is
        /// "always approximately 111 kilometers (69 miles)."
        ///
        /// - SeeAlso: https://developer.apple.com/documentation/mapkit/mkcoordinatespan
        static let approximateBaseDistance = Measurement(value: 111, unit: UnitLength.kilometers)
    }

    /// - Note: Here's how to create a 5-mile coordinate region
    /// ```
    /// let region = MKCoordinateRegion(center: location, latitudeDelta: Measurement(value: 5, unit: .miles))
    /// ```
    ///
    /// - Parameters:
    ///   - center: the center of the region
    ///   - latitudeDelta: the latitude delta described in a `UnitLength` measurement.
    public init(center: CLLocationCoordinate2D, latitudeDelta: Measurement<UnitLength>) {
        let adjustedLatitudeDelta = latitudeDelta.converted(to: .kilometers) / MKCoordinateRegion.Constants.approximateBaseDistance.value
        let span = MKCoordinateSpan(latitudeDelta: adjustedLatitudeDelta.value, longitudeDelta: 0)

        self.init(center: center, span: span)
    }
}
