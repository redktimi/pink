//
//  NoteDetailVC.swift
//  pink
//
//  Created by isdt on 2022/10/13.
//
/*
    详细笔记页面
 */

import UIKit
import FaveButton
import ImageSlideshow
import LeanCloud
import GrowingTextView

class NoteDetailVC: UIViewController {
    
    //自定义对象属性
    let note: LCObject
    var isLikeFromWaterfallCell = false             //笔记首页的点赞状态传值到笔记详情页面,判断详情页的当前用户是否点赞
    var delNoteFinished: (() -> ())?                //删除笔记闭包
    
    var comments: [LCObject] = []
    
    var isReply = false //用于判断用户按下textview的发送按钮时究竟是评论(comment)还是回复(reply)
    var commentSection = 0 //用于找出用户是对哪个评论进行的回复
    
//    var replies: [ExpandableReplies] = []
    var replyToUser: LCUser?
    
    var isFromMeVC = false
    var fromMeVCUser: LCUser?
    
    
    //上方bar(作者信息)
    @IBOutlet weak var authorAvatarBtn: UIButton!
    @IBOutlet weak var authorNickNameBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    //整个tableHeaderView
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var imageViewSlideshow: ImageSlideshow!          //自动轮播图片
    @IBOutlet weak var imageViewSlideshowH: NSLayoutConstraint!
    @IBOutlet weak var titleL: UILabel!
    //这里不使用UITextView是因其默认是滚动状态,不太方便搞成有多少就显示多少行的状态,实际开发中显示多行文本一般是用Label
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var channelBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    //整个tableView
    @IBOutlet weak var tableView: UITableView!
    
    //下方bar(点赞收藏评论)
    @IBOutlet weak var likeBtn: FaveButton!
    @IBOutlet weak var likeCountL: UILabel!             //点赞
    @IBOutlet weak var favBtn: FaveButton!
    @IBOutlet weak var favCountL: UILabel!              //关注
    @IBOutlet weak var commentCountBtn: UIButton!
    
    @IBOutlet weak var textViewBarView: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var textViewBarBottomConstraint: NSLayoutConstraint!
    
    
    //点赞数量初始化
    var likeCount = 0 {
        didSet{
            likeCountL.text = likeCount == 0 ? "点赞" : likeCount.formattedStr
        }
    }
    var currentLikeCount = 0                //当前点赞数量
    
    //收藏数量初始化
    var favCount = 0{
        didSet{
            favCountL.text = favCount == 0 ? "收藏" : favCount.formattedStr
        }
    }
    var currentFavCount = 0                 //当前关注数量
    
    //评论数量初始化
    var commentCount = 0{
        didSet{
            commentCountLabel.text = commentCount.formattedStr
            commentCountBtn.setTitle(commentCount == 0 ? "评论" : commentCount.formattedStr, for: .normal)
        }
    }
    
    //计算属性
    var author: LCUser?{ note.get(kAuthorCol) as? LCUser }
    var isLike: Bool { likeBtn.isSelected }
    var isFav:Bool { favBtn.isSelected }
    
    //给note: LCObject 创建初始化构造器
    init?(coder: NSCoder, note: LCObject) {
        self.note = note
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("必须传一些参数进来以构造本对象,不能单纯的用storyboard!.instantiateViewController构造本对象")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        config()
        setUI()

    }
    
    // MARK: tableHeaderView - 高度自适应
    //动态计算tableHeaderView的height(放在viewdidappear的话会触发多次),相当于手动实现了estimate size(目前cell已配备这种功能)
    override func viewDidLayoutSubviews() {
        adjustTableHeaderViewHeight()
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    // MARK: 底下Bar - 点赞事件
    @IBAction func like(_ sender: Any) { like() }
    
    // MARK: 底下Bar - 关注事件
    @IBAction func fav(_ sender: Any) { fav() }
    
    // MARK: 底下Bar - 评论事件
    @IBAction func comment(_ sender: Any) { comment() }
    
}