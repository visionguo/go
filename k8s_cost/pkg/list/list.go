package list

//初始化
type List struct {
	root Node   //头节点
	length int  //list长度
}

//返回list的指针
func New() *List {
	l := &List{}  //获取List{}的地址
    return l
}

//判空
func (l *List) IsEmpty() bool {
	return l.root.next == &l.root
}

//长度
func (l *List) Length() int {
	return l.length
}
//头插
func (l *List) PushFront(elements ...interface{})  {

}

//尾插
func (l *List) PushBack(elements ...interface{})  {

}

//查找
func (l *List) Find(elements ...interface{}) int {

}

//删除
func (l *List) Lpop() interface{}  {

}
//遍历
func (l *List) normalIndex(index int) int {

}