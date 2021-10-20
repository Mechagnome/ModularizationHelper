//
//  Kind.swift
//  SourceTool
//
//  Created by Ray Jiang on 2021/9/29.
//

import Foundation

enum Kind {
    case unknown
    case `enum`
    case enumcase
    case enumelement
    
    case `class`
    case `struct`
    case `protocol`
    case `associatedtype`
    case `typealias`
    case `extension`
    case genericTypeParam
    
    case varGlobal
    case varLocal
    case varInstance
    case varParameter
    case varStatic
    case varClass
    case funcInstance
    case funcStatic
    case funcClass
    case funcFree
    case funcSubscript
    
    case elem_id
    case elem_typeref
    case elem_init_expr
    /// 字典 Key value
    case elem_expr
    /// 表达式 Bool
    case elem_condition_expr
    /// switch 匹配到了一个结果
    case elem_pattern
    
    case `call`
    case `closure`
    /// 实际参数
    case `argument`
    case `dictionary`
    case `array`
    case `tuple`
    
    case `if`
    case `guard`
    case `foreach`
    case `while`
    case `switch`
    case `case`
    case `brace`
    
    case mark
    
    init(_ value: String) {
        switch value {
        case "source.lang.swift.decl.associatedtype":
            self = .associatedtype
        case "source.lang.swift.decl.class":
            self = .class
        case "source.lang.swift.decl.enum":
            self = .enum
        case "source.lang.swift.decl.enumcase":
            self = .enumcase
        case "source.lang.swift.decl.enumelement":
            self = .enumelement
        case "source.lang.swift.decl.extension":
            self = .extension
        case "source.lang.swift.decl.function.free":
            self = .funcFree
        case "source.lang.swift.decl.function.method.class":
            self = .funcClass
        case "source.lang.swift.decl.function.method.instance":
            self = .funcInstance
        case "source.lang.swift.decl.function.method.static":
            self = .funcStatic
        case "source.lang.swift.decl.function.subscript":
            self = .funcSubscript
        case "source.lang.swift.decl.generic_type_param":
            self = .genericTypeParam
        case "source.lang.swift.decl.protocol":
            self = .protocol
        case "source.lang.swift.decl.struct":
            self = .struct
        case "source.lang.swift.decl.typealias":
            self = .typealias
        case "source.lang.swift.decl.var.class":
            self = .varClass
        case "source.lang.swift.decl.var.global":
            self = .varGlobal
        case "source.lang.swift.decl.var.instance":
            self = .varInstance
        case "source.lang.swift.decl.var.local":
            self = .varLocal
        case "source.lang.swift.decl.var.parameter":
            self = .varParameter
        case "source.lang.swift.decl.var.static":
            self = .varStatic
        case "source.lang.swift.expr.argument":
            self = .argument
        case "source.lang.swift.expr.array":
            self = .array
        case "source.lang.swift.expr.call":
            self = .call
        case "source.lang.swift.expr.closure":
            self = .closure
        case "source.lang.swift.expr.dictionary":
            self = .dictionary
        case "source.lang.swift.expr.tuple":
            self = .tuple
        case "source.lang.swift.stmt.brace":
            self = .brace
        case "source.lang.swift.stmt.case":
            self = .case
        case "source.lang.swift.stmt.foreach":
            self = .foreach
        case "source.lang.swift.stmt.guard":
            self = .guard
        case "source.lang.swift.stmt.if":
            self = .if
        case "source.lang.swift.stmt.switch":
            self = .switch
        case "source.lang.swift.stmt.while":
            self = .while
        case "source.lang.swift.structure.elem.condition_expr":
            self = .elem_expr
        case "source.lang.swift.structure.elem.expr":
            self = .elem_expr
        case "source.lang.swift.structure.elem.id":
            self = .elem_id
        case "source.lang.swift.structure.elem.init_expr":
            self = .elem_init_expr
        case "source.lang.swift.structure.elem.pattern":
            self = .elem_pattern
        case "source.lang.swift.structure.elem.typeref":
            self = .elem_typeref
        case "source.lang.swift.syntaxtype.comment.mark":
            self = .mark
        default:
            self = .unknown
//            print("⚠️ Find new kind:\(value)")
//            fatalError()
        }
    }
}


/**
 枚举
 source.lang.swift.decl.enum
 枚举case
 source.lang.swift.decl.enumcase
 枚举元素
 source.lang.swift.decl.enumelement
 
 全局变量
 source.lang.swift.decl.var.global
 局部变量
 source.lang.swift.decl.var.local
 实例变量
 source.lang.swift.decl.var.instance
 形式参数
 source.lang.swift.decl.var.parameter
 source.lang.swift.decl.var.static
 source.lang.swift.decl.var.class
 实例方法
 source.lang.swift.decl.function.method.instance
 source.lang.swift.decl.function.method.static
 source.lang.swift.decl.function.method.class
 source.lang.swift.decl.extension
 
 source.lang.swift.decl.function.free
 source.lang.swift.decl.function.subscript
 source.lang.swift.decl.associatedtype
 source.lang.swift.decl.typealias
 source.lang.swift.decl.generic_type_param
 source.lang.swift.decl.protocol
 
 
 
 source.lang.swift.structure.elem.typeref
 source.lang.swift.structure.elem.init_expr
 字典 Key value
 source.lang.swift.structure.elem.expr
 表达式 Bool
 source.lang.swift.structure.elem.condition_expr
 switch 匹配到了一个结果
 source.lang.swift.structure.elem.pattern
 
 source.lang.swift.structure.elem.id
 
 方法
 source.lang.swift.expr.call
 闭包
 source.lang.swift.expr.closure
 实际参数
 source.lang.swift.expr.argument
 字典
 source.lang.swift.expr.dictionary
 source.lang.swift.expr.array
 source.lang.swift.expr.tuple
 
 
 if
 source.lang.swift.stmt.if
 switch
 source.lang.swift.stmt.switch
 case
 source.lang.swift.stmt.case
 方法域(大括号)
 source.lang.swift.stmt.brace
 guard
 source.lang.swift.stmt.guard
 source.lang.swift.stmt.foreach
 
 mark
 source.lang.swift.syntaxtype.comment.mark
 */
