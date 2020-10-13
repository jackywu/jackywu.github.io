pattern="/Users/wucheng/codebase/blog/jackywu.github.io"
sed -i "s/$pattern//g"  `grep -rl  '$pattern'  .`
