import UIKit

class ViewController: UIViewController {
    private let tableView: UITableView
    private let dataSourse: DataSource
    private let viewModel: ViewModel

    init() {
        self.tableView = UITableView(
            frame: .zero,
            style: .insetGrouped
        )
        
        self.viewModel = ViewModel()
        
        self.dataSourse = Self.makeDataSourse(
            tableView: self.tableView,
            viewModel: self.viewModel
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        makeSnapshot()
    }
}

extension ViewController {
    private func setupUI() {
        view.backgroundColor = .white
        setupNavigationBar()
        setupTableView()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Task 4"
        navigationItem.rightBarButtonItem = .init(
            title: "Shuffle",
            primaryAction: UIAction { [weak self] _ in
                self?.shuffleDataSnapshot()
            }
        )
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.reuseIdentifire
        )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


extension ViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        moveAndSelectRowIfNeeded(indexPath: indexPath)
    }
}

extension ViewController {
    private func makeSnapshot(animate: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(
            viewModel.rows.map(\.id),
            toSection: .main
        )
        dataSourse.apply(
            snapshot,
            animatingDifferences: animate
        )
    }

    private func moveAndSelectRowIfNeeded(indexPath: IndexPath) {
        guard let row = viewModel.get(index: indexPath.row) else {
            return
        }

        let isSelectedRow = viewModel.isSelectedRow(id: row.id)
        let isFirstRow = (indexPath == .init(row: 0, section: 0))
        let currentFirstItem = dataSourse.itemIdentifier(for: .init(row: 0, section: 0))
        let needMoveToTop = isSelectedRow == false && isFirstRow == false

        viewModel.toggleSelectingRow(id: row.id)

        var snapshot = dataSourse.snapshot()
        
        if needMoveToTop, let currentFirstItem {
            snapshot.moveItem(
                row.id,
                beforeItem: currentFirstItem
            )
        }

        snapshot.reloadItems([row.id])
        
        dataSourse.apply(snapshot, animatingDifferences: true) { [weak self] in
            if needMoveToTop {
                self?.viewModel.pushRowToTop(id: row.id)
            }
        }
    }

    private func shuffleDataSnapshot() {
        viewModel.shuffle()
        makeSnapshot(animate: true)
    }
}

extension ViewController {
    private typealias DataSource = UITableViewDiffableDataSource<Section, Row.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row.ID>

    private struct Row: Identifiable, Hashable {
        let id: Int
        let rawValue: Int
        let isSelected: Bool

        init(
            id: Int,
            rawValue: Int,
            isSelected: Bool
        ) {
            self.id = id
            self.rawValue = rawValue
            self.isSelected = isSelected
        }

        static func == (lhs: Row, rhs: Row) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    private enum Section: Hashable {
        case main
    }

    private static var reuseIdentifire: String {
        "reuseCell"
    }

    private static func makeDataSourse(
        tableView: UITableView,
        viewModel: ViewModel
    ) -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, rowId in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: reuseIdentifire,
                for: indexPath
            )

            guard let rowData = viewModel.get(index: indexPath.row) else {
                return cell
            }

            var configuration = cell.defaultContentConfiguration()
            configuration.text = "\(rowData.rawValue)"
            cell.contentConfiguration = configuration
            cell.accessoryType = viewModel.isSelectedRow(id: rowData.id) ? .checkmark : .none

            return cell
        }
    }
}
