import UIKit

struct CustomInputComponent<Base: Renderable>: Renderable, Focusable {
    let customInput: CustomInput
    let focusEligibility: FocusEligibility
    let highlightColor: UIColor?
    let base: Base

    init(
        source: Base,
        customInput: CustomInput,
        contentStatus: FocusEligibility.ContentStatus,
        highlightColor: UIColor?
    ) {
        self.customInput = customInput
        self.highlightColor = highlightColor
        self.base = source
        self.focusEligibility = .eligible(contentStatus)
    }

    func render(in view: ComponentView) {
        view.inputNodes = customInput
        view.highlightingGesture.didTap = .manual
        view.highlightingGesture.highlightColor = highlightColor
        view.highlightingGesture.stylingView = view.containedView

        base.render(in: view.containedView)
    }
}

extension CustomInputComponent {
    final class ComponentView: InteractiveView, FocusableView {
        var inputNodes: CustomInput? {
            didSet {
                guard isFirstResponder else { return }
                if let nodes = inputNodes {
                    customInputView?.update(nodes)
                    reloadInputViews()
                } else {
                    _ = resignFirstResponder()
                }
            }
        }

        var customInputView: InputView?
        var focusToolbar: FocusToolbar?
        let containedView = Base.View.generate() as! Base.View

        override init(frame: CGRect) {
            super.init(frame: frame)

            containedView.add(to: self).pinEdges(to: self)
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) { fatalError() }

        public override var inputView: UIView? {
            return customInputView
        }

        public override var inputAccessoryView: UIView? {
            return focusToolbar
        }

        public override func becomeFirstResponder() -> Bool {
            if let nodes = inputNodes {
                customInputView = InputView()
                focusToolbar = FocusToolbar(view: self)
                customInputView!.update(nodes)
            }

            if super.becomeFirstResponder() {
                highlightingGesture.isHighlighted = true

                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyboardDidDisappear),
                    name: UIResponder.keyboardDidHideNotification,
                    object: nil
                )

                return true
            }

            customInputView = nil
            focusToolbar = nil
            return false
        }

        public override func resignFirstResponder() -> Bool {
            highlightingGesture.isHighlighted = false
            return super.resignFirstResponder()
        }

        public func focus() {
            _ = becomeFirstResponder()
        }

        func neighboringFocusEligibilityDidChange() {
            focusToolbar?.updateFocusEligibility(with: self)
            reloadInputViews()
        }

        @objc func keyboardDidDisappear() {
            if isFirstResponder { _ = resignFirstResponder() }
            customInputView = nil
            focusToolbar = nil
            NotificationCenter.default.removeObserver(
                self,
                name: UIResponder.keyboardDidHideNotification,
                object: nil
            )
        }
    }
}
