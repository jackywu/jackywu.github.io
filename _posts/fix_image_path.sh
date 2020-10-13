pattern="/Users/wucheng/codebase/blog/jackywu.github.io"
escaped_pattern="\/Users\/wucheng\/codebase\/blog\/jackywu.github.io"
# sed -i "s/$escaped_pattern//g"  `grep -rl  '$pattern'  .`
file_list=`grep -rl  "$pattern"  .|grep -v fix_image_path.sh`
# echo $file_list
# sed -i "s/$escaped_pattern//g" $file_list
echo "s/$escaped_pattern//g" $file_list
