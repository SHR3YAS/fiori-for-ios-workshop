//
//  ExpenseDetailTableViewController.swift
//  SAP-Expense
//
//  Created by Stadelman, Stan on 4/4/18.
//  Copyright © 2018 SAP SE or an SAP affiliate company.  All rights reserved.
//

import SAPFiori
import UIKit

class ExpenseDetailTableViewController: FUIFormTableViewController {

    // MARK: - Model

    private var expense: ExpenseItemType!

    func setExpense(_ expense: ExpenseItemType) {
        self.expense = expense
        self.title = self.expense.itemid
        self.tableView.reloadData()
    }

    // TODO: add receipts to ExpenseItemType
    private var receipts: [UIImage] = [#imageLiteral(resourceName: "Receipt.jpg")]

    // MARK: View controller hooks

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(FUIKeyValueFormCell.self, forCellReuseIdentifier: FUIKeyValueFormCell.reuseIdentifier)
        self.tableView.register(FUIAttachmentsFormCell.self, forCellReuseIdentifier: FUIAttachmentsFormCell.reuseIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: FUIAttachmentsFormCell.reuseIdentifier, for: indexPath) as! FUIAttachmentsFormCell
            cell.attachmentsController.dataSource = self
            cell.attachmentsController.delegate = self
            cell.isEditable = false
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: FUIKeyValueFormCell.reuseIdentifier, for: indexPath) as! FUIKeyValueFormCell

//        cell.valueTextView.textColor = UIColor.preferredFioriColor(forStyle: .primary1)
        cell.isEditable = false

        let emptyString = " - "
        switch indexPath.row {
        case 0:
            cell.keyName = "Expense Type"
            cell.value = self.expense.expenseType?.description ?? self.expense.expensetypeid ?? emptyString
        case 1:
            cell.keyName = "Vendor"
            cell.value = self.expense.vendor ?? emptyString
        case 2:
            cell.keyName = "Transaction Date"
            if let date = self.expense.itemdate {
                cell.value = DateFormatter(.medium).string(from: date.utc())
            } else {
                cell.value = emptyString
            }
        case 3:
            cell.keyName = "Location"
            cell.value = self.expense.location ?? emptyString
        case 4:
            cell.keyName = "Amount"
            if let amount = self.expense.amount, let amountString = NumberFormatter(.currency).string(from: amount.doubleValue() as NSNumber) {
                cell.value = amountString
            } else {
                cell.value = emptyString
            }
        case 5:
            cell.keyName = "Currency"
            cell.value = self.expense.currency?.description ?? self.expense.currencyid ?? emptyString

        default:
            cell.keyName = "Payment"
            cell.value = self.expense.paymentType?.description ?? self.expense.paymenttypeid ?? emptyString
        }

        return cell
    }
}

// MARK: - Attachments data source & delegate

extension ExpenseDetailTableViewController: FUIAttachmentsViewControllerDataSource, FUIAttachmentsViewControllerDelegate {
    func numberOfAttachments(in _: FUIAttachmentsViewController) -> Int {
        return self.receipts.count
    }

    func attachmentsViewController(_: FUIAttachmentsViewController, iconForAttachmentAtIndex index: Int) -> (image: UIImage, contentMode: UIViewContentMode)? {
        guard self.receipts.count > 0 else { return nil }
        return (image: self.receipts[index], contentMode: .scaleAspectFill)
    }

    func attachmentsViewController(_: FUIAttachmentsViewController, urlForAttachmentAtIndex _: Int) -> URL? {
        return nil
    }

    func attachmentsViewController(_: FUIAttachmentsViewController, didPressDeleteAtIndex index: Int) {
        self.receipts.remove(at: index)
    }

    func attachmentsViewController(_: FUIAttachmentsViewController, couldNotPresentAttachmentAtIndex _: Int) {
        let alertController = UIAlertController(title: "Attachment Unavailable", message: "Cannot read attachment. It might not be downloaded on device", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { [weak alertController] _ in
            alertController?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        navigationController?.present(alertController, animated: true, completion: nil)
    }
}
