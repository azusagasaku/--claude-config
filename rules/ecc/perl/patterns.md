---
paths:
  - "**/*.pl"
  - "**/*.pm"
  - "**/*.t"
  - "**/*.psgi"
  - "**/*.cgi"
---
# Perl 模式

> 本文件扩展了 [common/patterns.md](../common/patterns.md)，补充 Perl 特定的设计模式。

## 仓库模式

在接口后使用 **DBI** 或 **DBIx::Class**：

```perl
package MyApp::Repo::User;
use Moo;

has dbh => (is => 'ro', required => 1);

sub find_by_id ($self, $id) {
    my $sth = $self->dbh->prepare('SELECT * FROM users WHERE id = ?');
    $sth->execute($id);
    return $sth->fetchrow_hashref;
}
```

## DTO / 值对象

使用 **Moo** 类配合 **Types::Standard**（与 Python 的 dataclass 类似）：

```perl
package MyApp::DTO::User;
use Moo;
use Types::Standard qw(Str Int);

has name  => (is => 'ro', isa => Str, required => 1);
has email => (is => 'ro', isa => Str, required => 1);
has age   => (is => 'ro', isa => Int);
```

## 资源管理

- 始终使用 **三参数 open** 配合 `autodie`。
- 文件操作使用 **Path::Tiny**：

```perl
use autodie;
use Path::Tiny;

my $content = path('config.json')->slurp_utf8;
```

## 模块接口

使用 `Exporter 'import'` 配合 `@EXPORT_OK`，而非 `@EXPORT`：

```perl
use Exporter 'import';
our @EXPORT_OK = qw(parse_config validate_input);
```

## 依赖管理

使用 **cpanfile** + **carton** 实现可复现的安装：

```bash
carton install
carton exec prove -lr t/
```

## 参考

现代 Perl 模式和惯用法参见技能：`perl-patterns`。
