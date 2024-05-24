enum Modification<Element> {
    case insert(offset: Int, element: Element)
    case remove(offset: Int, element: Element)
    case update(offset: Int, oldElement: Element, newElement: Element)
    case move(element: Element, fromOffset: Int, toOffset: Int)

    var remove: (offset: Int, element: Element)? {
        switch self {
        case let .remove(offset, element):
            (offset, element)
        default:
            nil
        }
    }
}

extension CollectionDifference where ChangeElement: Hashable {
    
    func inferringModifications() -> [Modification<ChangeElement>] {
        let withMoves = inferringMoves()
        var result: [Modification<ChangeElement>] = []
        for change in withMoves {
            switch change {
            case let .insert(offset, element, associatedWith):
                if associatedWith != nil {
                    continue
                }
                if let index = result.firstIndex(where: { $0.remove?.offset == offset }) {
                    let oldElement = result[index].remove!.element
                    result[index] = .update(offset: offset, oldElement: oldElement, newElement: element)
                    continue
                }
                result.append(.insert(offset: offset, element: element))
            case let .remove(offset, element, associatedWith):
                if let associatedWith {
                    result.append(.move(element: element, fromOffset: offset, toOffset: associatedWith))
                    continue
                }
                result.append(.remove(offset: offset, element: element))
            }
        }
        return result
    }
}
