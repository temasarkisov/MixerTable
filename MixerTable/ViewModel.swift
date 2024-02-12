import Foundation

struct Row: Identifiable, Hashable {
    let id: Int
    let rawValue: Int

    static func == (lhs: Row, rhs: Row) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

final class ViewModel {
    private(set) var rows: [Row] = ViewModel.makeDefaultRows()
    private var selectedRowIds: Set<Row.ID> = []
}

extension ViewModel {
    func isSelectedRow(id: Row.ID) -> Bool {
        selectedRowIds.contains(id)
    }

    func get(index: Int) -> Row? {
        guard index >= 0, index < rows.count else {
            return nil
        }
        return rows[index]
    }

    func toggleSelectingRow(id: Row.ID) {
        if selectedRowIds.contains(id) {
            selectedRowIds.remove(id)
            return
        }
        selectedRowIds.insert(id)
    }

    func pushRowToTop(id: Row.ID) {
        let index = rows.firstIndex { $0.id == id }
        guard let index else { return }
        
        let row = rows[index]
        rows.remove(at: index)
        rows.insert(row, at: 0)
    }

    func shuffle() {
        rows.shuffle()
    }
}

extension ViewModel {
    private static func makeDefaultRows() -> [Row] {
        (0..<100).map { Row(id: $0, rawValue: $0) }
    }
}
