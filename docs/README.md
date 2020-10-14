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

这篇文章的主角GraphQL与Flutter，可能很多人最多只接触过其中之一，或者是都未曾接触过。将这两个技术栈结合使用的过程让我有一种“介绍前女友给现在的女朋友认识”的诡异又兴奋的感觉。这两样技术虽然风马牛不相及，但却有这么几个共同点：

- 都是不温不火（至少在国内），很少有公司会大规模的使用它们。
- 既有拥簇者，亦有唱衰者，常常见到唱衰者冷眼旁观拥簇者爱不释手。
- 都是为了挑战甚至是替代现有技术或者方案（Flutter vs RN等，GraphQL vs RESTFul），当然，它们也可以和“对手”通力合作，比如基于GraphQL的BFF层（Backend For Frontend，你可以理解为架在客户端与真实接口之间的中间层，通常起到网关/数据聚合清洗的作用 ）。

很明显我同时是这两样技术的拥簇者，可能是没有钻研的足够深入看到深藏其后的弊端，亦或是没有在生产环境面对它们带来的问题焦头烂额过，所以目前我依然对Flutter和GraphQL十分看好。

## GraphQL

GraphQL我接触的早一些，用它写过BFF，也用它作为过主API，我自己写的脚手架预置的后端模板也为GraphQL提供了等同于RESTFul的支持（Express/Koa(Apollo)/Midway），但我暂时没有到特别精通的地步。这篇文章虽然更期望读者具有GraphQL与Flutter基础，但由于二者代码极强的可读性，我认为只需要稍作解释就能让零基础的同学也能get到代码的大致意思。

简单的介绍下GraphQL：

- 不同于REST，GraphQL不需要区分HTTP方法和API路径，通常只使用GET和POST方法，并只请求/graphql路径。

  就像REST用GET方法取得数据，POST方法修改数据一样，GraphQL使用`query` `mutation` `subscription`这三种操作对请求目的进行区分，分别代表只读、变更与订阅。

- 请求中的参数，REST通常将参数放在URL（GET）或是body（如POST）中，GraphQL同样根据请求方法进行区分，GET下放置于query参数中（也就是URL），如POST下放置于body中。其参数通常包含`query` `operation` `variables`这三个字段。

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

在前不久Flutter刚刚release了1.22版本，虽然它的GitHub仓库Issue依然堆积如山，未解决的Bug数也数不过来，开发者怨天载道民不聊生（？），但由于Google以及Fuscia的背书，它的未来还是值得期待的。

说实话，我觉得Flutter和React蛮像的：

- 一切皆组件（Widget/Component），可能Flutter贯彻的还要更彻底一些，是真的啥都能是控件，但这也带来一直被很多人诟病的嵌套地狱问题。
- 写起TSX来更像，Dart和TS都是强类型的，虽然一个前置类型一个后置类型，还有熟悉的回调函数啥的。
- Dart从ES中，Flutter从React中，都借鉴了不少，比如Dart的async/await，Future（Promise）等，Flutter中的InheritedWidget与React中的context，见我之前写过的xxx，甚至你可以在Flutter中使用Redux的心智模型，见闲鱼技术部的fish-redux。

Flutter的语法就这里只做简单的展示，就是我们本文要实现的一个小控件：文本输入框。我觉得排除掉逻辑部分后，UI部分你可以直接当React代码来看。

```dart
Container(
  padding: const EdgeInsets.only(top: 80.0),
  child: TextField(
    maxLength: 10,
    controller: personName,
    decoration: InputDecoration(
      icon: Icon(Icons.text_format),
      labelText: "Name",
    ),
  ),
),
```

`Container`作为最外层的容器，用于控制内部的子控件样，我觉得有点像Div标签。遇事不决就套一层。`TextField`是内置的文本域控件，预先集成了相关功能。 `decoration`和 `InputDecoration`则是对该输入框进行装饰的属性配置， `icon`是输入框前面的图标， `labelText`则是输入框的标签。

这个简单的控件应该给你展示了一些Flutter的魅力，说实话，我自己是适应了一段时间才接受并喜欢上这样的语法的，所以如果你感觉不太适应，不妨再忍忍？

学习Flutter的话，由于我也才开始学习一个月，自己也还在摸索学习方式中，这里就给出我收藏的还没有机会用上的资源

以下正文的代码中，没有Flutter基础的同学可能看不太懂，但我本篇文章的目的也不是细致的带你Flutter、GraphQL入门（GraphQL的系列文章我在构思了，但一直感觉很大，我想从GraphQL入门一路写到基于相关的主流技术栈构建中大型应用再到解析原理等等，而目前的我应该是写不好的），而是尝试带涉猎过其中之一的同学领略另外一方的魅力，顺便撩拨下都未曾涉猎的同学的好奇心，毕竟前端就是要爱折腾嘛。

## 动手！

这篇文章我们会完成两个demo，ToDo List 和 Person Admin，都是很简单的CRUD应用，我用了两种不同的代码风格来完成：声明式的前者与命令式的后者。

demo需要的GraphQL API我已经预先完成，你可以先clone [demo仓库](https://github.com/linbudu599/flutter_graphql_example)， 启动位于`/server`下的服务器，并使用GraphiQL进行调试。

> 你可以理解为GraphiQL是专为GraphQL打造的增强版PostMan，用于快速浏览接口文档、发起请求、查看结果。
