//
//  Instafilter.swift
//  InstafilterTCA
//
//  Created by hn on 2025/12/2.
//

import ComposableArchitecture
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

@Reducer
struct Instafilter {
    enum FilterType: String, CaseIterable, Equatable {
        case Crystallize,Edges,GaussianBlur,Pixellate,SepiaTone,UnsharpMask,Vignette,BumpDistortion,BoxBlur,NoiseReduction
    }
    @ObservableState
    struct State: Equatable {
        var selectedItem: PhotosPickerItem?
        var processedImage: Image?
        var filterIntensity = 0.9
        var filterRadius = 10.0
        var showingFilters = false
        @Shared(.appStorage("filterCount")) var filterCount = 0
        var filterType: FilterType = .SepiaTone
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case changeFilterButtonTapped
        case imageProcessed(Image)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        
        @CasePathable
        enum ConfirmationDialog: Equatable {
            case filterButtonTapped(FilterType)
        }
    }
    
    @Dependency(\.storeKitClient) var storeKitClient
    @Dependency(\.imageCacheClient) var imageCacheClient
    
    let context = CIContext()
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(let bindingAction):
                switch bindingAction.keyPath {
                case \.filterIntensity, \.filterRadius, \.filterType:
                    return .run { [state] send in
                        await applyProcessing(state: state, send: send)
                    }
                case \.selectedItem:
                    return .run { [state] send in
                        await loadImage(state: state)
                        await applyProcessing(state: state, send: send)
                    }
                default:
                    break
                }
                return .none
            case .changeFilterButtonTapped:
                state.confirmationDialog = .filterConfirmation
                return .none
            case .imageProcessed(let image):
                state.processedImage = image
                return .none
            case .confirmationDialog(.presented(.filterButtonTapped(let filterType))):
                state.filterType = filterType
                state.$filterCount.withLock {
                    $0 += 1
                }
                return .run { [state] send in
                    await applyProcessing(state: state, send: send)
                    if state.filterCount > 3 {
                        await storeKitClient.requestReview()
                    }
                }
            case .confirmationDialog:
                return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
    
    func loadImage(state: State) async {
        guard let imageData = try? await state.selectedItem?.loadTransferable(type: Data.self) else { return }
        guard let inputImage = UIImage(data: imageData) else { return }
        guard let beginImage = CIImage(image: inputImage) else { return }
        await imageCacheClient.setImage(beginImage)
    }
    
    func applyProcessing(state: State, send: Send<Action>) async {
        guard let inputImage = await imageCacheClient.getImage() else { return }
        let filter = { () -> CIFilter in
            switch state.filterType {
            case .Crystallize:
                return .crystallize()
            case .Edges:
                return .edges()
            case .GaussianBlur:
                return .gaussianBlur()
            case .Pixellate:
                return .pixellate()
            case .SepiaTone:
                return .sepiaTone()
            case .UnsharpMask:
                return .unsharpMask()
            case .Vignette:
                return .vignette()
            case .BumpDistortion:
                return .bumpDistortion()
            case .BoxBlur:
                return .boxBlur()
            case .NoiseReduction:
                return .noiseReduction()
            }
        }()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        let inputKeys = filter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { filter.setValue(state.filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { filter.setValue(state.filterRadius, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { filter.setValue(state.filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = filter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)
        await send(.imageProcessed(Image(uiImage: uiImage)))
    }
}

extension ConfirmationDialogState where Action == Instafilter.Action.ConfirmationDialog {
    static let filterConfirmation = ConfirmationDialogState {
        TextState("Select a filter")
    } actions: {
        for filterType in Instafilter.FilterType.allCases {
            ButtonState(action: .filterButtonTapped(filterType)) {
                TextState(filterType.rawValue)
            }
        }
    }
}

struct InstafilterView: View {
    @Bindable var store: StoreOf<Instafilter>
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                //image are
                PhotosPicker(selection: $store.selectedItem) { [processedImage = store.processedImage] in
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    }else {
                        ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: $store.filterIntensity)
                        .disabled(store.selectedItem == nil)
                }
                .padding(.vertical)
                
                HStack {
                    Text("Radius")
                    Slider(value: $store.filterRadius, in: 0...100)
                        .disabled(store.selectedItem == nil)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") {
                        store.send(.changeFilterButtonTapped)
                    }
                    .disabled(store.selectedItem == nil)
                    
                    Spacer()
                    
                    if let processedImage = store.processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
        }
    }
}

