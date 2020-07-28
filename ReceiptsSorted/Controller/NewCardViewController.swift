//
//  NewCardViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 29/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import CoreData

class NewCardViewController /*: UIViewController*/ {

//    @IBOutlet weak var tblView: UITableView!
//
//    private let userChecker = UserChecker()
//    
//    private let coreDataStack = CoreDataStack(modelName: "PaymentsData")
//    lazy var fetchedResultsController: NSFetchedResultsController<Payment> = {
//
//        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
//        let fetchedResultsController = NSFetchedResultsController( fetchRequest: fetchRequest,
//                                                                   managedObjectContext: coreDataStack.managedContext,
//                                                                   sectionNameKeyPath: nil,
//                                                                   cacheName: nil)
//        return fetchedResultsController
//    }()
//
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureTableView()
//        setupSearchBar()
//        setupNoReceiptsImage()
//        setupSelectionHelperView()
////        sortButton.setTitle(dropDownMenu.getButtonTitle(for: cardViewModel.sortType), for: .normal)
//
////        cardViewModel.delegate = self
////        cardViewModel.isSelectionEnabled.onValueChanged { [weak self] selectionEnabled in
////            self?.cardViewModel.allSelected = false
////            self?.tblView.reloadData()
////        }
////
////        cardViewModel.selectAllButtonText.onValueChanged { [weak self] (buttonText) in
////            self?.selectAllButton.setTitle(buttonText, for: .normal)
////        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        if  !userChecker.wasSwipeDemoShown() {
//            guard let cell = tblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PaymentTableViewCell else { return }
//            presentSwipeDemo(forCell: cell, animated: false)
//            previewSwipeActions(for: cell)
//
//            userChecker.setSwipeDemoAsShown() // set UserDefaults as shown
//        }
//    }
//
//
//    //MARK: - Configurations
//
//        private func configureTableView() {
//            tblView.dataSource = self
//            tblView.delegate = self
//            tblView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
//            tblView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) //separator lines
//            tblView.tableFooterView = UIView() //Removes uneeded separator lines at the end of TableView
//        }
//
//
//    //    func setupDataSource() -> UITableViewDiffableDataSource<String, Payment> {
//    //      return UITableViewDiffableDataSource(tableView: tblView) { [unowned self] (tableView, indexPath, payment) -> UITableViewCell? in
//    //        let cell = tableView.dequeueReusableCell(withIdentifier: self.paymentCellIdentifier, for: indexPath) as! PaymentTableViewCell
//    //        return self.cardVM.set(cell: cell, with: payment)
//    //      }
//    //    }
//
//
//        private func setupSearchBar() {
//            searchBar.delegate = self
//            searchBar.returnKeyType = UIReturnKeyType.done
//
//            searchAndSortView.translatesAutoresizingMaskIntoConstraints = false
//            searchTopAnchor = searchAndSortView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -(searchAndSortView.frame.size.height))
//            searchBottomAnchor = searchAndSortView.bottomAnchor.constraint(equalTo: self.SortSegmentedControl.topAnchor, constant: -25)
//            NSLayoutConstraint.activate([searchTopAnchor!, searchBottomAnchor!])
//        }
//
//        private func setupNoReceiptsImage() {
//            view.addSubview(noReceiptsImage)
//            noReceiptsImage.translatesAutoresizingMaskIntoConstraints = false
//            noReceiptsImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//            noReceiptsImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
//            noReceiptsImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
//
//            let offsetY: CGFloat = cardStartPointY/2
//            noReceiptImageCenterYAnchor = noReceiptsImage.centerYAnchor.constraint(equalTo: tblView.centerYAnchor, constant: -offsetY)
//            noReceiptImageCenterYAnchor?.isActive = true
//        }
//
//        private func setupSelectionHelperView() {
//            selectionHelperView.layer.cornerRadius = 25
//            selectionHelperView.layer.applyShadow(color: .black, alpha: 0.1, x: 0, y: -3, blur: 3)
//            selectionHelperView.clipsToBounds = false
//
//            bottomSHViewConstraint.isActive = false
//            bottomSHViewConstraint = selectionHelperView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: selectionHelperView.frame.height)
//            bottomSHViewConstraint.isActive = true
//        }
//
//
//        // MARK: - Swipe preview setup
//
//        private func presentSwipeDemo(forCell cell: PaymentTableViewCell, animated: Bool) {
//            let onboardingVC = OnboardingViewController(showWelcomePage: false, addCornerRadius: false)
//            let textHelper = TextHelper()
//
//            let text = textHelper.create(text: "← Swipe to mark receipt as ", bold: false, fontSize: 18)
//            text.append(textHelper.create(text: "Claimed ", bold: true, fontSize: 18))
//            text.append(textHelper.create(text: " or to Remove it completely", bold: false, fontSize: 18))
//
//            let yOrigin = cell.frame.origin.y + cardStartPointY + SortSegmentedControl.frame.origin.y + SortSegmentedControl.frame.height
//            let showFrame = CGRect(x: cell.frame.origin.x,
//                                   y: yOrigin,
//                                   width: cell.frame.width,
//                                   height: cell.frame.height - 1)
//
//            onboardingVC.add(info: OnboardingInfo(showRect: showFrame, text: text))
//
//            onboardingVC.modalPresentationStyle = .overFullScreen
//            present(onboardingVC, animated: animated)
//        }
//
//
//        private func previewSwipeActions(for cell: PaymentTableViewCell) {
//
//            let tickSwipeLabel = createDemoSwipeLabel(text: swipeActions.tickText, backgroundColour: .tickSwipeActionColour)
//            let removeSwipeLabel = createDemoSwipeLabel(text: swipeActions.removeText, backgroundColour: .lightRed)
//
//            let removeSwipeWidth: CGFloat = removeSwipeLabel.sizeThatFits(tickSwipeLabel.frame.size).width + 15
//            let tickSwipeWidth: CGFloat = tickSwipeLabel.sizeThatFits(tickSwipeLabel.frame.size).width + 15
//
//            cell.insertSubview(removeSwipeLabel, belowSubview: cell.contentView)
//            removeSwipeLabel.translatesAutoresizingMaskIntoConstraints = false
//            removeSwipeLabel.widthAnchor.constraint(equalToConstant: removeSwipeWidth).isActive = true
//            removeSwipeLabel.heightAnchor.constraint(equalToConstant: cell.bounds.height).isActive = true
//            removeSwipeLabel.trailingAnchor.constraint(equalTo:  cell.trailingAnchor, constant: removeSwipeWidth).isActive = true
//
//            cell.insertSubview(tickSwipeLabel, belowSubview: cell.contentView)
//            tickSwipeLabel.translatesAutoresizingMaskIntoConstraints = false
//            tickSwipeLabel.widthAnchor.constraint(equalToConstant: tickSwipeWidth).isActive = true
//            tickSwipeLabel.heightAnchor.constraint(equalToConstant: cell.bounds.height).isActive = true
//            tickSwipeLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: removeSwipeWidth + tickSwipeWidth).isActive = true
//
//            cell.layoutIfNeeded()
//
//            UIView.animate(withDuration: 0.3, animations: {
//                cell.transform = CGAffineTransform.identity.translatedBy(x: -(tickSwipeLabel.bounds.width + removeSwipeLabel.bounds.width),y: 0)
//            }) { _ in
//                UIView.animateKeyframes(withDuration: 0.3, delay: 3, options: [], animations: {
//                    cell.transform = CGAffineTransform.identity
//                }, completion: { _ in
//                    tickSwipeLabel.removeFromSuperview()
//                    removeSwipeLabel.removeFromSuperview()
//                })
//            }
//        }
//
//
//        private func createDemoSwipeLabel(text: String, backgroundColour: UIColor) -> UILabel {
//            let label = UILabel(frame: CGRect.zero)
//            label.text = text
//            label.numberOfLines = 0
//            label.backgroundColor = backgroundColour
//            label.textColor = .white
//            label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//            label.textAlignment = .center
//            return label
//        }
//
//
//        //MARK: - TableVew Scrolling
//
//        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            if (fractionComplete > 0 && fractionComplete < 1) ||
//                   (nextState == .Expanded && fractionComplete < 1) ||
//                   (nextState == .Collapsed && fractionComplete < 0) {
//                tblView.contentOffset.y = 0
//            }
//
//            if (searchBar.isFirstResponder){
//                searchBar.resignFirstResponder()
//            }
//        }
}
