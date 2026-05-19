---
paths:
  - "**/*.pl"
  - "**/*.pm"
  - "**/*.t"
  - "**/*.psgi"
  - "**/*.cgi"
---
# Perl 安全

> 本文件扩展了 [common/security.md](../common/security.md)，补充 Perl 特定的安全实践。

## 污点模式

- 所有 CGI/Web 面向用户的脚本添加 `-T` 标志。
- 执行任何外部命令前先清理 `%ENV`（`$ENV{PATH}`、`$ENV{CDPATH}` 等）。

## 输入验证

- 使用白名单正则去除污点标记，不应使用 `/(.*)/s` 绕过检查。
- 所有用户输入使用显式模式验证：

```perl
if ($input =~ /\A([a-zA-Z0-9_-]+)\z/) {
    my $clean = $1;
}
```

## 文件 I/O

- **仅使用三参数 open**，不应再使用双参数 open。
- 使用 `Cwd::realpath` 防止路径遍历：

```perl
use Cwd 'realpath';
my $safe_path = realpath($user_path);
die "Path traversal" unless $safe_path =~ m{\A/allowed/directory/};
```

## 进程执行

- 使用 **列表形式的 `system()`**，不应使用单字符串形式。
- 捕获输出使用 **IPC::Run3**。
- 不应使用带变量插值的反引号。

```perl
system('grep', '-r', $pattern, $directory);  # 安全
```

## SQL 注入防护

始终使用 DBI 占位符，不应将变量拼接到 SQL 中：

```perl
my $sth = $dbh->prepare('SELECT * FROM users WHERE email = ?');
$sth->execute($email);
```

## 安全扫描

使用严重级别 4+ 配合 security 主题执行 **perlcritic**：

```bash
perlcritic --severity 4 --theme security lib/
```

## 参考

Perl 安全模式、污点模式和安全 I/O 的全面内容参见技能：`perl-security`。
