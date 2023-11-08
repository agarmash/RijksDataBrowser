//
//  ArtObjectsOverviewViewModelMapper.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 08/11/2023.
//

import Foundation

protocol ArtObjectsOverviewViewModelMapperProtocol {
    func makePageHeaderViewModel(
        pageNumber: Int
    ) -> ArtObjectsSectionHeaderViewModelProtocol
    
    func makeErrorHeaderViewModel(
        didTapOnView: @escaping () -> Void
    ) -> ErrorSectionHeaderViewModelProtocol
    
    func makeArtObjectCellViewModel(
        with artObject: Collection.ArtObject
    ) -> ArtObjectsOverviewCellViewModelProtocol
}

final class ArtObjectsOverviewViewModelMapper: ArtObjectsOverviewViewModelMapperProtocol {
    
    private let imageRepository: ArtObjectImagesRepositoryProtocol
    
    init(imageRepository: ArtObjectImagesRepositoryProtocol) {
        self.imageRepository = imageRepository
    }
    
    func makePageHeaderViewModel(
        pageNumber: Int
    ) -> ArtObjectsSectionHeaderViewModelProtocol {
        ArtObjectsSectionHeaderViewModel(pageNumber: pageNumber)
    }
    
    func makeErrorHeaderViewModel(
        didTapOnView: @escaping () -> Void
    ) -> ErrorSectionHeaderViewModelProtocol {
        ErrorSectionHeaderViewModel(didTapOnView: didTapOnView)
    }
    
    func makeArtObjectCellViewModel(
        with artObject: Collection.ArtObject
    ) -> ArtObjectsOverviewCellViewModelProtocol {
        ArtObjectsOverviewCellViewModel(with: artObject, imageRepository: imageRepository)
    }
}
