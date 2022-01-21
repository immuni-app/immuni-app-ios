// GreenCertificateVC.swift
// Copyright (C) 2020 Presidenza del Consiglio dei Ministri.
// Please refer to the AUTHORS file for more information.
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import Foundation
import Models
import Tempura

class GreenCertificateVC: ViewControllerWithLocalState<GreenCertificateView> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupInteraction() {
        rootView.didTapBack = { [weak self] in
            self?.dispatch(Hide(Screen.greenCertificate, animated: true))
        }
        
        rootView.didTapGenerateGreenCertificate = { [weak self] in
            self?.dispatch(Logic.Home.ShowGenerateGreenCertificate())
        }
        rootView.didTapDeleteGreenCertificate = { [weak self] index in
            let deleteConfirmBox = UIAlertController(
                title: L10n.HomeView.GreenCertificate.Confirm.title,
                message: L10n.HomeView.GreenCertificate.Confirm.message,
                preferredStyle: UIAlertController.Style.alert
            )
            deleteConfirmBox.addAction(UIAlertAction(title: L10n.confirm, style: .default, handler: { (_: UIAlertAction!) in
                guard let id = self?.viewModel?.greenCertificates?[index].id,
                      let greenCertificates = self?.viewModel?.greenCertificates else { return }
                self?.dispatch(Logic.Home.DeleteGreenCertificate(id: id))
                self?.viewModel?.greenCertificates = greenCertificates.filter { $0.id != greenCertificates[index].id }
                if index > 0 {
                    self?.viewModel?.currentDgc = index-1
                }

            }))
            deleteConfirmBox.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
            self?.present(deleteConfirmBox, animated: true, completion: nil)
            
        }
        
        rootView.showOrderInfoModal = { [weak self] in
            let deleteConfirmBox = UIAlertController(
                title: L10n.HomeView.GreenCertificate.InfoModal.title,
                message: L10n.HomeView.GreenCertificate.InfoModal.message,
                preferredStyle: UIAlertController.Style.alert
            )
            deleteConfirmBox.addAction(UIAlertAction(title: L10n.HomeView.GreenCertificate.InfoModal.button, style: .default, handler: { (_: UIAlertAction!) in
                self?.dispatch(Logic.Home.UpdateFlagShowModalDgc())
            }))
            self?.present(deleteConfirmBox, animated: true, completion: nil)
        }
        
        rootView.didTapDiscoverMore = { [weak self] dgc in
            self?.dispatch(Logic.Home.ShowGreenCertificateDetail(dgc: dgc))
        }
        
        rootView.didTapSaveGreenCertificate = { [weak self] index in
            guard let self = self, let model = self.viewModel else { return }
            
            if let greenCertificates = model.greenCertificates {
                
                let dataDecoded: Data? = Data(base64Encoded: greenCertificates[model.currentDgc].greenCertificate, options: .ignoreUnknownCharacters)
              if let dataDecoded = dataDecoded, let decodedimage = UIImage(data: dataDecoded) {
                if let imageToSave = decodedimage.addImagePadding(x: 20, y: 20) {
                    UIImageWriteToSavedPhotosAlbum(imageToSave, self,  #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                }
              }
           
        }
        }
    }
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if ((error) != nil) {
            dispatch(Logic.DataUpload.ShowSaveGreenCertificateErrorAlert())
        } else {
            dispatch(Logic.DataUpload.SaveDigitalGreenCertificate())
        }
    }

}

// MARK: - LocalState

struct GreenCertificateLS: LocalState {
    
    var greenCertificates: [GreenCertificate]?

    /// True if it's not possible to execute a new request.
    var isLoading: Bool = false
}
