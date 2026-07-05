import Foundation
import SwiftUI

extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) {
            $0.next
        }.first { $0 is UIViewController } as? UIViewController
    }
}

private struct NavigationPopGestureDisabler: UIViewRepresentable {
    let disabled: Bool

    func makeUIView(context: Context) -> some UIView { UIView() }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            guard let navigationController = uiView.parentViewController?.navigationController else { return }
            navigationController.interactivePopGestureRecognizer?.isEnabled = !disabled
            if #available(iOS 26.0, *) {
                navigationController.interactiveContentPopGestureRecognizer?.isEnabled = !disabled
            }
        }
    }
}

public extension View {
    @ViewBuilder
    func navigationPopGestureDisabled(_ disabled: Bool) -> some View {
        background {
            NavigationPopGestureDisabler(disabled: disabled)
        }
    }
}
