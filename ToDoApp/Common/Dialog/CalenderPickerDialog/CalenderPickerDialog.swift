//
//  CalenderPickerDialog.swift
//  MoneyManager
//
//  Created by MeiMei on 30/07/2023.
//

import UIKit

class CalenderPickerDialog: UIViewController {
    // MARK: Views
    private lazy var dimmedBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var headerView = CalendarPickerHeaderView { [weak self] in
        guard let self = self else { return }

        self.dismiss()
    }

    private lazy var footerView = CalendarPickerFooterView(
    didTapLastMonthCompletionHandler: { [weak self] in
        guard let self = self else { return }

        let previousDate = self.calendar.date(byAdding: .month,
                                             value: -1,
                                             to: self.baseDate) ?? self.baseDate
        
        self.baseDate = previousDate
        
    },didTapNextMonthCompletionHandler: { [weak self] in
        guard let self = self else { return }

        let nextDate = self.calendar.date(byAdding: .month,
                                          value: 1,
                                          to: self.baseDate) ?? self.baseDate
        
        self.baseDate = nextDate
    })

    // MARK: Calendar Data Values

    private let selectedDate: Date
    private var baseDate: Date {
        didSet {
            days = generateDaysInMonth(for: baseDate)
            collectionView.reloadData()
            headerView.baseDate = baseDate
            footerView.baseDate = baseDate
        }
    }

    private lazy var days = generateDaysInMonth(for: baseDate)

    private var numberOfWeeksInBaseDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }

    private let selectedDateChanged: ((Date) -> Void)
    private let calendar = Calendar(identifier: .gregorian)

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()

    // MARK: Initializers

    init(baseDate: Date, selectedDateChanged: @escaping ((Date) -> Void)) {
        self.selectedDate = baseDate
        self.baseDate = baseDate
        self.selectedDateChanged = selectedDateChanged

        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        definesPresentationContext = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemGroupedBackground

        view.addSubview(dimmedBackgroundView)
        view.addSubview(collectionView)
        view.addSubview(headerView)
        view.addSubview(footerView)
        footerView.baseDate = baseDate

        var constraints = [
            dimmedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        constraints.append(contentsOf: [
            collectionView.leadingAnchor.constraint(
                equalTo: view.readableContentGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.readableContentGuide.trailingAnchor),
            collectionView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: 10),
            collectionView.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 0.4)
        ])

        constraints.append(contentsOf: [
            headerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 85),
      
            footerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 60)
        ])

        NSLayoutConstraint.activate(constraints)

        collectionView.register(
            CalendarDateCollectionViewCell.self,
            forCellWithReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        headerView.baseDate = baseDate
    }
    
    override func viewWillTransition(to size: CGSize,with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    
    func dismiss() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

// MARK: - Day Generation
extension CalenderPickerDialog {
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata {
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: baseDate)?.count,
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate)) else {
            throw CalendarDataError.metadataGeneration
        }

        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return MonthMetadata(numberOfDays: numberOfDaysInMonth, firstDay: firstDayOfMonth, firstDayWeekday: firstDayWeekday)
    }

    func generateDaysInMonth(for baseDate: Date) -> [Day] {
        guard let metadata = try? monthMetadata(for: baseDate) else {
            preconditionFailure("An error occurred when generating the metadata for \(baseDate)")
        }

        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay

        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
                .map { day in
                    let isWithinDisplayedMonth = day >= offsetInInitialRow
                    let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)

                    return generateDay(offsetBy: dayOffset,
                                       for: firstDayOfMonth,
                                       isWithinDisplayedMonth: isWithinDisplayedMonth)
                }

        days += generateStartOfNextMonth(using: firstDayOfMonth)

        return days.filter({ !$0.date.isInFuture })
    }

    func generateDay(offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        let date = calendar.date(byAdding: .day,
                                 value: dayOffset,
                                 to: baseDate) ?? baseDate

        return Day(date: date,
                   number: dateFormatter.string(from: date),
                   isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                   isWithinDisplayedMonth: isWithinDisplayedMonth
        )
    }

    func generateStartOfNextMonth(using firstDayOfDisplayedMonth: Date) -> [Day] {
        guard let lastDayInMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                                 to: firstDayOfDisplayedMonth) else {
            return []
        }

        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else {
            return []
        }

        let days: [Day] = (1...additionalDays)
            .map { generateDay(offsetBy: $0,for: lastDayInMonth,isWithinDisplayedMonth: false) }

        return days
    }

    enum CalendarDataError: Error {
        case metadataGeneration
    }
}

// MARK: - UICollectionViewDataSource
extension CalenderPickerDialog: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->    UICollectionViewCell {
      let day = days[indexPath.row]

      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier, for: indexPath) as! CalendarDateCollectionViewCell

      cell.day = day
      return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalenderPickerDialog: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        selectedDateChanged(day.date)
        self.dismiss()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInBaseDate
        return CGSize(width: width, height: height)
    }
}

