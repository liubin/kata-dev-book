# Kata Containers 项目管理

本文档主要介绍一下项目管理中的组织结构。相比其他开源项目，Kata Containers 采取了一种非常精简的构成模式：

- 由架构委员会（Architecture Committee）负责项目整体管理、技术决策，重大事项。
- 开发者参与项目的开发

## Four opens

Kata Containers 项目遵循 OpenStack 基金会的 [four opens](https://governance.openstack.org/tc/reference/opens.html) 原则：

- open source
- open design
- open development
- open community

技术方面的问题都由 contributors 以架构委员会来进行决策。

## Developers

### Contributor

- 过去 12 个月之内有被合并的代码。
- 可以参与架构委员会选举投票。

### Maintainer

- 活跃开发者
- Maintainer 具有合并代码的权限
- 需要由其他 Maintainers 提名

## Architecture Committee

架构委员会负责架构决策、标准化等整体技术方向，由 5 名委员构成。

当前架构委员会成员（by 2022.8）如下：

- `Eric Ernst` ([`egernst`](https://github.com/egernst)), [Apple](https://apple.com/).
- `Samuel Ortiz` ([`sameo`](https://github.com/sameo)), [Apple](https://apple.com/).
- `Archana Shinde` ([`amshinde`](https://github.com/amshinde)), [Intel](https://www.intel.com).
- `Peng Tao` ([`bergwolf`](https://github.com/bergwolf)), [Ant Financial](https://www.antfin.com/index.htm?locale=en_US).
- `Fabiano Fidêncio` ([`fidencio`](https://github.com/fidencio)), [Intel](https://www.intel.com).

架构委员会的成员会在每年在 2 月和 9 月进行两次选举，其中在 2 月的选举中会轮换 2 个席位，在 9 月的选举中会轮换 3 个席位，保持总共 5 个席位不变。

另外，同一个公司不能在架构委员会中超过 2 个席位。

关于选举的具体情况，可以参考[官方文档](https://github.com/kata-containers/community/tree/master/elections)。
