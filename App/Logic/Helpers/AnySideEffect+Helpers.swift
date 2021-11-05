//
//  AnySideEffect+Helpers.swift
//  Immuni
//
//  Created by Mauro Bolis on 26/10/21.
//

import Foundation
import Katana
import Hydra

/// Extension that contains some helper method
extension AnySideEffectContext {
  /**
   Dispatches an item and wait for the related promise to be resolved.
   This is a shortcut for `try Hydra.await(dispatch(item))`.

   - parameter dispatchable: the item to dispatch
  */
  func awaitDispatch(_ dispatchable: Dispatchable) throws {
    try Hydra.await(self.anyDispatch(dispatchable))
  }
}
