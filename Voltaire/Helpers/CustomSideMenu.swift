//
//  CustomSideMenu.swift
//  Voltaire
//
//  Created by Kilian Balaguer on 10/7/26.
//

import SwiftUI

/// Shared panel shape — matches the original CustomSideMenu look
enum SideMenuPanelShape {
    static func make() -> AnyShape {
        if #available(iOS 26, *) {
            return AnyShape(ConcentricRectangle(corners: .concentric, isUniform: true))
        } else {
            return AnyShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
        }
    }
}

struct CustomSideMenu<MenuContent: View, Content: View>: View {
    var isEnabled: Bool = true
    var sideBarWidth: CGFloat = 280
    @Binding var isExpanded: Bool
    @ViewBuilder var menuContent: (_ progress: CGFloat) -> MenuContent
    @ViewBuilder var content: (_ progress: CGFloat) -> Content
    ///View Properties
    @State private var progress: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var haptics: Bool = false

    init(
        isEnabled: Bool = true,
        sideBarWidth: CGFloat = 280,
        isExpanded: Binding<Bool> = .constant(false),
        @ViewBuilder menuContent: @escaping (_ progress: CGFloat) -> MenuContent,
        @ViewBuilder content: @escaping (_ progress: CGFloat) -> Content
    ) {
        self.isEnabled = isEnabled
        self.sideBarWidth = sideBarWidth
        self._isExpanded = isExpanded
        self.menuContent = menuContent
        self.content = content
    }

var body: some View {
        ZStack(alignment: .leading) {
            /// Base layer — system background (black/white), same as settings
            Color(.systemBackground)
                .ignoresSafeArea()

            /// Sidebar background stays opaque while the menu is on-screen
            Color(.systemBackground)
                .ignoresSafeArea()
                .frame(width: sideBarWidth)
                .frame(maxHeight: .infinity)
                .opacity(progress > 0.001 ? 1 : 0)

            menuContent(progress)
                .opacity(progress)
                .frame(width: sideBarWidth)
                .frame(maxHeight: .infinity)

            /// Main panel — content stays full size; rounded look comes from the shape fill behind it
            content(progress)
                .containerRelativeFrame(.horizontal)
                .frame(maxHeight: .infinity)
                .background {
                    /// Opaque on the content itself — system background like settings
                    Color(.systemBackground)
                        .ignoresSafeArea()
                }
                .overlay {
                    SideMenuPanelShape.make()
                        .fill(.fill.tertiary)
                        .stroke(.fill.secondary, lineWidth: 1)
                        .ignoresSafeArea()
                        .contentShape(.rect)
                        .onTapGesture {
                            haptics.toggle()
                            withAnimation(animation) {
                                xOffset = 0
                                progress = 0
                                isExpanded = false
                            }
                        }
                        .opacity(progress)
                }
                .offset(x: xOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect)
        .gesture(
            CustomSideMenuGesture(isEnabled: isEnabled, isExpanded: $isExpanded) { gesture in
                let state = gesture.state
                let translation = gesture.translation(in: gesture.view).x + (isExpanded ? sideBarWidth : 0)
                let velocity = gesture.velocity(in: gesture.view).x / 5

                if state == .began || state == .changed {
                    xOffset = min(max(translation, 0), sideBarWidth)
                    progress = xOffset / sideBarWidth
                } else {
                    withAnimation(animation) {
                        let shouldExpand = (xOffset + velocity) > (sideBarWidth / 2)
                        if shouldExpand {
                            if !isExpanded { haptics.toggle() }
                            xOffset = sideBarWidth
                            progress = 1
                            isExpanded = true
                        } else {
                            if isExpanded { haptics.toggle() }
                            xOffset = 0
                            progress = 0
                            isExpanded = false
                        }
                    }
                }
            }
        )
        .sensoryFeedback(.impact(weight: .light), trigger: haptics)
        .onChange(of: isExpanded) { _, expanded in
            withAnimation(animation) {
                if expanded {
                    xOffset = sideBarWidth
                    progress = 1
                } else {
                    xOffset = 0
                    progress = 0
                }
            }
        }
    }

    var animation: Animation {
        .interactiveSpring(duration: 0.2, extraBounce: 0.02)
    }
}

/// Custom Gesture For Side Menu
fileprivate struct CustomSideMenuGesture: UIGestureRecognizerRepresentable {
    var isEnabled: Bool
    @Binding var isExpanded: Bool
    var handle: (UIPanGestureRecognizer) -> ()
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.delegate = context.coordinator
        gesture.maximumNumberOfTouches = 1
        return gesture
    }

    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {
        recognizer.isEnabled = isEnabled
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: CustomSideMenuGesture
        init(parent: CustomSideMenuGesture) {
            self.parent = parent
        }
    }
}
