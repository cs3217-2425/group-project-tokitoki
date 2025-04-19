//
//  CraftingPopupViewDelegate.swift
//  TokiToki
//
//  Created by Wh Kang on 19/4/25.
//


import UIKit

protocol CraftingPopupViewDelegate: AnyObject {
    func popupViewDidTapCraft(_ popupView: CraftingPopupView)
    func popupView(_ popupView: CraftingPopupView, didSelectItem item: Equipment)
}

class CraftingPopupView: UIView {
    let tableView = UITableView()
    let craftButton = UIButton(type: .system)
    weak var delegate: CraftingPopupViewDelegate?

    var items: [Equipment] = [] {
        didSet { tableView.reloadData() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)

        craftButton.setTitle("Craft", for: .normal)
        craftButton.translatesAutoresizingMaskIntoConstraints = false
        craftButton.addTarget(self, action: #selector(craftTapped), for: .touchUpInside)
        addSubview(craftButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: craftButton.topAnchor),
            craftButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            craftButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            craftButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            craftButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func craftTapped() {
        delegate?.popupViewDidTapCraft(self)
    }
}

extension CraftingPopupView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.popupView(self, didSelectItem: item)
    }
}
