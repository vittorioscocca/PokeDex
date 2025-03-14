//
//  BidableState.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation

/// Rappresenta una porzione specifica dello stato di una vista, utilizzabile per il binding bidirezionale in SwiftUI.
///
/// Il protocollo `BindableState` definisce un'associazione generica per lo stato bindabile,
/// permettendo di creare ViewState che possano essere legati in maniera bidirezionale alle view.
/// L'associazione generica è definita tramite il tipo associato `BindStateType`, che per impostazione predefinita è `Void`.
protocol BindableState {
    /// Il tipo associato che rappresenta lo stato bindabile.
    /// Il valore predefinito è `Void`, che indica che non sono previsti dati bindabili.
    associatedtype BindStateType = Void
    
    /// La proprietà che contiene lo stato da bindare.
    var bindings: BindStateType { get set }
}

extension BindableState where BindStateType == Void {
    /// Implementazione di default per `bindings` quando il tipo associato è `Void`.
    ///
    /// Questa implementazione consente di utilizzare `BindableState` anche quando non si desidera
    /// gestire dati bindabili, ossia quando lo stato non necessita di binding.
    /// Se si tenta di impostare un valore a `bindings` in questo caso, viene generato un errore fatale,
    /// poiché il binding non è supportato per il tipo `Void`.
    var bindings: Void {
        get { }
        set {
            fatalError("Non è possibile utilizzare il binding per il tipo Void.")
        }
    }
}
