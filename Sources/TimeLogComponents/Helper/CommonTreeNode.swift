//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/5/31.
//

import Foundation
import IdentifiedCollections

public struct CommonTreeNode<Value: Equatable & Identifiable>: Identifiable, Equatable {
    public var value: Value
    
    public var id: Value.ID {
        value.id
    }
    
    public var children: IdentifiedArrayOf<CommonTreeNode<Value>>? = nil
    
    public mutating func insert(_ node: CommonTreeNode<Value>) {
        if self.children != nil {
            self.children?.append(node)
        } else {
            self.children = [node]
        }
    }
    
    public func toList() -> IdentifiedArrayOf<Value> {
        var result: IdentifiedArrayOf<Value> = .init()
        result.append(value)
        
        if let children {
            result.append(contentsOf: children.flatMap { $0.toList() })
        }
        
        return result
    }
    
    public func get(_ id: Value.ID) -> CommonTreeNode<Value>? {
        // 当前节点就是
        if self.id == id {
            return self
        }
        
        // 没有子节点就不找了
        guard let children else {
            return nil
        }
        
        // 子节点中存在
        if let result = children[id: id] {
            return result
        }
        
        // 子节点继续向下
        for item in children {
            if let result = item.get(id) {
                return result
            }
        }
        
        return nil
    }
}

extension CommonTreeNode {
    // 在树中合并跟节点
    public static func mergeRoot(root: CommonTreeNode, tree: inout IdentifiedArrayOf<CommonTreeNode>) {
        if let index = tree.firstIndex(where: { $0.id == root.id }) { // 树中包含当前节点
            guard tree[index].children != nil  else { // 树已经没有子节点了，直接拿过来
                tree[index].children = root.children
                
                return
            }
            
            guard root.children?.first != nil else { // root 没有子节点
                return
            }
            
            // root 和 tree 都还有子节点
            mergeRoot(root: root.children!.first!, tree: &tree[index].children!)
        } else { // 树中没有当前节点，直接插入
            tree.append(root)
            return
        }
    }
    
    public static func transform<TargetValue: Equatable & Identifiable>(
        tree: IdentifiedArrayOf<CommonTreeNode>,
        _ transformer: (Value) -> TargetValue,
        emptyValue: () -> Value
    ) -> IdentifiedArrayOf<CommonTreeNode<TargetValue>> {
        let root: CommonTreeNode = .init(value: emptyValue(), children: tree)
        let targetRoot = transform(root: root, transformer)
        
        return targetRoot.children ?? []
    }
    
    static private func transform<TargetValue: Equatable & Identifiable>(
        root: CommonTreeNode,
        _ transformer: (Value) -> TargetValue
    ) -> CommonTreeNode<TargetValue> {
        let targetValue = transformer(root.value)
        
        guard let children = root.children else {
            return .init(value: targetValue)
        }
        
        var targetChildren: IdentifiedArrayOf<CommonTreeNode<TargetValue>> = []
        for node in children {
            targetChildren.append(transform(root: node, transformer))
        }
        
        return .init(value: targetValue, children: targetChildren)
    }
}
