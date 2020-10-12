# TITLE

## PRE

- 基本的Flutter知识
- 基本GraphQL语法
- 基本Node知识
- 环境要求

## INCLUDE

- Flutter Widget相关(本篇文章涉及到的)
- GraphQL服务器启动
  - GraphiQL调试
- Flutter-GraphQL 安装与使用
  - 与React-Apollo的渊源
  - Query/Mutation 操作与控件
  - UI与服务器同步 缓存命中问题
- 获取数据并展示
- 完成列表项
- 删除列表项
- 新增列表项
- 整体感受阐述

**缓存相关!**

## 命令式与编程式

- 命令式: 根据result.loading / result.hasException 等切换UI
- 编程式: 手动获取client, 调用client的方法 client.query / client.mutate



## 前言

这篇文章的主角GraphQL与Flutter，可能很多人最多只接触过其中之一，或者是都未曾接触过。将这两个技术栈结合使用的过程让我有一种“介绍前女友给现在的女朋友认识”的诡异又兴奋感觉。这两样技术虽然风马牛不相及，但却有这么几个共同点：

- 都是不温不火（至少在国内），很少有公司会大规模的使用它们。
- 既有拥簇者，亦有唱衰者，常常见到唱衰者冷眼旁观拥簇者爱不释手。
- 都是为了挑战甚至是替代现有技术或者方案（Flutter vs RN等，GraphQL vs RESTFul）。



很明显我同时是这两样技术的拥簇者，可能是没有钻研的足够深入看到深藏其后的弊端，亦或是没有在生产环境面对它们带来的问题焦头烂额过，目前我依然对Flutter和GraphQL持十分看好的观点。

## GraphQL

GraphQL我接触的早一些，用它写过BFF，也用它作为过主API，我自己写的脚手架预置的后端模板也为GraphQL提供了等同于RESTFul的支持（Express/Koa/Apollo/Midway），但我暂时没有到特别精通的地步。这篇文章虽然更期望读者具有GraphQL与Flutter基础，但由于二者代码极强的可读性，我认为只需要稍作解释就能让零基础的同学也能get到大致意思。

简单的介绍下GraphQL：

- 不同于REST，GraphQL不需要区分HTTP方法和API路径，通常只使用GET方法，并请求/graphql路径。

- GraphQL强调所见即所得，即对后端的请求中声明了自己需要的字段，如：

  ```gql
  query {
  	Person {
  		name
  		age
  	}
  }
  ```

  以上这个查询语句声明了前端只需要name与age属性，后端的GraphQL服务器会进行处理，确保不会返回多余的字段。

- 强类型，后端的GraphQL Schema定义了服务器支持的对象及其字段，在定义过程中需要使用标量进行规范入参与各字段类型，包括String、Int、Boolean、Float以及更复杂的枚举、接口、对象类型、输入对象类型等。举例来说：

  ```gql
  type Job {
  	salary: Float
  	desc: String
  }
  
  type Person {
  	name: String!
  	age: Int
  	isMarried: Boolean
  	job: Job
  }
  ```

  > !表示当前字段返回必定的是非null值



如果你想要深入些学习GraphQL，可以先从[官网]开始，然后从其生态开始感受GraphQL的魅力，如express-graphql、apollo-server、apollo-client。

> GraphQL虽然是后端需要进行的改造，并且的确后端层面受到的关注程度更高，但为了应用性能以及更友好的编码体验，其前端生态同样有着重要作用，目前常用的主要是Relay与Apollo-Client，二者差异可以一读我之前翻译的【Apollo-Client vs Relay】。
>
> P.S. GraphQL 与 Relay 都是FaceBook的开源作品。

### Flutter

在前不久Flutter刚刚release了1.22版本，虽然它的GitHub仓库Issue依然堆积如山，未解决的Bug数也数不过来，但由于Fuscia的背书，它的未来还是值得等待的。

说实话，我觉得Flutter和React蛮像的：

- 一切皆组件（Widget/Component），可能Flutter贯彻的还要更彻底一些，具体为什么你可以在下文的第一个例子中的代码感受到。
- 写起TSX来更像，Dart和TS都是强类型的，虽然一个前置类型一个后置类型
- Dart从ES中，Flutter从React中，都借鉴了不少，比如Dart的async/await，Future（Promise）等，Flutter中的InheritedWidget与React中的context，见我之前写过的xxx，甚至你可以在Flutter中使用Redux的心智模型，见闲鱼技术部的fish-redux。

Flutter的语法就不做展示了，因为我觉得排除掉逻辑部分，UI部分你可以直接当React代码来看。

学习Flutter的话，由于我也才开始学习一个月不到，自己也还在摸索学习方式中，这里就给出我收藏的还没有机会用上的资源

以下正文的代码中，没有Flutter基础的同学可能看不太懂，但我本篇文章的目的也不是细致的带你Flutter、GraphQL入门（GraphQL的系列文章我在构思了，但一直感觉很大，我想从GraphQL入门一路写到基于相关的主流技术栈构建中大型应用再到解析原理等等，目前的我应该是写不好的），而是尝试带涉猎过其中之一的同学领略另外一方的魅力，顺便撩拨下都未曾涉猎的同学的好奇心，毕竟前端就是要爱折腾嘛。