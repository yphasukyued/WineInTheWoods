import UIKit

class MyTableViewCell: UITableViewCell {
    
    var myLabel1: UILabel!
    var myLabel2: UILabel!
    var myDetail: UILabel!
    var myButton1 : UIButton!
    var mapButton : UIButton!
    var webButton : UIButton!
    var phoneButton : UIButton!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        myLabel1 = UILabel()
        myLabel1.textColor = UIColor.whiteColor()
        myLabel1.font = UIFont(name: "TrebuchetMS", size: 16)
        contentView.addSubview(myLabel1)
        
        myLabel2 = UILabel()
        myLabel2.textColor = UIColor.whiteColor()
        myLabel2.font = UIFont(name: "TrebuchetMS", size: 12)
        contentView.addSubview(myLabel2)
        
        myDetail = UILabel()
        myDetail.textColor = UIColor.whiteColor()
        myDetail.font = UIFont(name: "TrebuchetMS", size: 12)
        contentView.addSubview(myDetail)
        
        myButton1 = UIButton()
        contentView.addSubview(myButton1)
        
        mapButton = UIButton()
        contentView.addSubview(mapButton)
        
        webButton = UIButton()
        contentView.addSubview(webButton)

        phoneButton = UIButton()
        contentView.addSubview(phoneButton)
    }
    
    var isObserving = false;
    class var expandedHeight: CGFloat { get { return 100 } }
    class var defaultHeight: CGFloat  { get { return 50  } }
    
    func checkHeight() {
        myDetail.hidden = (frame.size.height < MyTableViewCell.expandedHeight)
        mapButton.hidden = (frame.size.height < MyTableViewCell.expandedHeight)
        webButton.hidden = (frame.size.height < MyTableViewCell.expandedHeight)
        phoneButton.hidden = (frame.size.height < MyTableViewCell.expandedHeight)
    }
    
    func watchFrameChanges() {
        if !isObserving {
            addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Initial], context: nil)
            isObserving = true;
        }
    }
    
    func ignoreFrameChanges() {
        if isObserving {
            removeObserver(self, forKeyPath: "frame")
            isObserving = false;
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
}
