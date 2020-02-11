#:/bin/bash
# $filename

# 第一个冒号表示忽略错误；字符后面的冒号表示该选项必须有自己的参数,没有则不能加参数。
while getopts ":a:b:cdef" opt; do
  case $opt in
    a)
      echo "this is -a the arg is: $OPTIND $OPTARG" 
      # 两个内置变量，及OPTARG和OPTIND
      ;;
    b)
      echo "this is -b the arg is : $OPTIND $OPTARG" 
      ;;
    c)
      echo "this is -c the arg is : $OPTARG" 
      ;;
    ?)
      echo "[ERROR]Invalid option: $OPTARG" 
      exit 1
      ;;
  esac
done

