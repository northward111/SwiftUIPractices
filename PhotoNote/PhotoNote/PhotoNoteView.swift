//
//  PhotoNoteView.swift
//  PhotoNote
//
//  Created by hn on 2025/10/31.
//

import MapKit
import SwiftUI

struct PhotoNoteView: View {
    let photoNote: PhotoNote
    var uiImage: UIImage? {
        UIImage(data: photoNote.photo)
    }
    var body: some View {
        VStack {
            Group {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }else {
                    ContentUnavailableView(
                        "No photo",
                        systemImage: "exclamationmark.circle"
                    )
                }
            }
            .frame(maxHeight: 400)
            Text(photoNote.name)
                .font(.headline)
            if let coordinate = photoNote.coordinate {
                Map(
                    initialPosition: MapCameraPosition
                        .region(
                            MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(
                                    latitudeDelta: 0.1,
                                    longitudeDelta: 0.1
                                )
                            )
                        )
                ) {
                    Marker(photoNote.name, coordinate: coordinate)
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle(photoNote.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PhotoNoteView(photoNote: .example())
}
