//
//  ViewController.swift
//  music
//
//  Created by robert on 2022/10/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    var index = 0
    let player = AVPlayer()
    var updateTime = CMTime()
    let musics = [
    
        ["fileName": "Beyond Mediocrity","title":"1.Beyond Mediocrity","composer":"Beyond Mediocrity"],
        ["fileName": "Talented","title":"2.Kumachan","composer":"Talented"],
        ["fileName": "Somewhere in time","title":"3.Accusefive","composer":"Somewhere in time"],
        
    ]
    var musicsToPlay : [String] = []
    @IBOutlet weak var playerPanelView: UIView!
    @IBOutlet weak var musicProgressBarSlider: UISlider!
    @IBOutlet weak var loopButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var musicPicImageView: UIImageView!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var composerLabel: UILabel!
    @IBOutlet weak var durationLabe: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    //操作面板加入圓角的函式
    func addRoundCorners (cornerRadius: Double) {
        playerPanelView.layer.cornerRadius = CGFloat(cornerRadius)
        playerPanelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    //切換音樂播放時間slider的按鈕成小顆的
    func setProgressBarThumb() {
        let smallConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium, scale: .small)
        let thumb = UIImage(systemName: "circle.fill", withConfiguration: smallConfig)
        musicProgressBarSlider.setThumbImage(thumb, for: .normal)
    }
    
    //將播放暫停鈕的圖片放大，並且設定播放模式及暫停模式個別顯示的圖片
    func setPlayButtonImage() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 65, weight: .light, scale: .large)
        let playIcon = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
        let pauseIcon = UIImage(systemName: "pause.circle", withConfiguration: largeConfig)
        //.normal為暫停模式，所以顯示play圖片
        playButton.setImage(playIcon, for: .normal)
        //.selected為播放模式，所以顯示pause圖片
        playButton.setImage(pauseIcon, for: .selected)
    }
    
    //將重複播放按鈕圖片放大一點，並且設定重複及不重複模式個別顯示的按鈕
    func switchLoopMode() {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular, scale: .medium)
        let loopModeOffIcon = UIImage(systemName: "repeat.circle", withConfiguration: config)
        let loopModeOnIcon = UIImage(systemName: "repeat.circle.fill", withConfiguration: config)
        //.normal為不重複模式
        loopButton.setImage(loopModeOffIcon, for: .normal)
        //.selected為重複模式
        loopButton.setImage(loopModeOnIcon, for: .selected)
    }
    
    //將隨機播放按鈕放大一點
    func setShuffleButtonImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular, scale: .medium)
        let shuffleIcon = UIImage(systemName: "shuffle.circle", withConfiguration: config)
        shuffleButton.setImage(shuffleIcon, for: .normal)
    }

    //格式化顯示音樂時間的函式，以Double型態的秒數為參數
    func formatedTime(_ secs: Double) -> String {
        var timeString = ""
        let formatter = DateComponentsFormatter()
        //.positional樣式為將時間不同單位以冒號區隔
        formatter.unitsStyle = .positional
        //只需要使用分跟秒就好
        formatter.allowedUnits = [.minute, .second]
        //不同秒數下有些需要補0所以有不同的格式
        if secs < 10 && secs >= 0 {
            timeString = "0:0\(formatter.string(from: secs)!)"
        } else if secs < 60 && secs >= 10 {
            timeString = "0:\(formatter.string(from: secs)!)"
        } else {
            timeString = formatter.string(from: secs)!
        }
        return timeString
    }
    
    
    func setMusicToPlay(fileName: String, index: Int) {
        //生成playItem，並取代成為player的currentItem
        let filePath = Bundle.main.url(forResource: fileName, withExtension:".mp3")!
        let playItem = AVPlayerItem(url: filePath)
        player.replaceCurrentItem(with: playItem)
        //設定音樂名稱、作曲者、音樂圖片
        musicTitleLabel.text = musics[index]["title"]!
        composerLabel.text = musics[index]["composer"]!
        let musicPicture = UIImage(named: "\(musics[index]["fileName"]!).jpeg")
        musicPicImageView.image = musicPicture
        //抓取playItem的時間長度並轉化為負數的剩餘時間，並調整播放時間的slider最大值
        let playItemDuration =  playItem.asset.duration.seconds
        durationLabe.text = formatedTime(0 - playItemDuration)
        musicProgressBarSlider.maximumValue = Float(playItemDuration)
        //重置目前播放時間為00:00
        currentTimeLabel.text = formatedTime(0)
    }
    
    var isDragSlider = false
    
    //觀察播放音樂目前的時間函式
    func musicCurrentTime() {
        //timeScale和time照抄官方文件範例，微調為每1秒發動一次
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)
        //將player掛上週期性時間觀察器，除了最後更新介面的閉包外其餘參數皆是照抄官方文件和學長姐的作業
        player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { (time) in
            //如果目前播放的item狀態是可以正常播放的才執行裡面介面更新程式
            if (self.player.currentItem?.status == .readyToPlay) && !self.isDragSlider {
                //抓取目前音樂的時間
                let currentTime = self.player.currentTime().seconds
                var leftTime =  (self.player.currentItem?.duration.seconds)!
                //使用條件來處理手機模擬器會觀察到負數秒數的問題
                if currentTime > 0 {
                    //計算剩下多少時間
                    leftTime =  (self.player.currentItem?.duration.seconds)! - currentTime
                    //設定目前時間label的text
                    self.currentTimeLabel.text = self.formatedTime(currentTime)
                    //設定音樂播放時間slider的value
                    self.musicProgressBarSlider.value = Float(currentTime)
                } else {
                    leftTime =  (self.player.currentItem?.duration.seconds)!
                    self.currentTimeLabel.text = self.formatedTime(0)
                    self.musicProgressBarSlider.value = Float(0)
                }
                //設定剩餘時間label的text，加上負號
                self.durationLabe.text = "-\(self.formatedTime(leftTime))"
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //呼叫播放操作面板加入圓角函式
        addRoundCorners(cornerRadius: 60)
        
        //設定播放按鈕圖片
        setPlayButtonImage()
        
        //設定播放進度slider按鈕
        setProgressBarThumb()
        
        //設定重複模式按鈕圖片
        switchLoopMode()
        //設定隨機播放圖片
        setShuffleButtonImage()
       
        //將要播放的音樂檔名擷取出來放到musicsToPlay陣列
        for music in musics {
            musicsToPlay.append(music["fileName"]!)
        }
        
        //初始化player要播放的音樂和介面
        setMusicToPlay(fileName: musicsToPlay[0], index: 0)
        
        //呼叫加入播放時間觀察器函式
        musicCurrentTime()
        
        //加上一個觀察器，播放完時自動播放下一個item，依據是否重複播放index會自動改變或者不改變播放同一首音樂
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
            if !self.loopButton.isSelected {
                self.index = (self.index + 1) % self.musicsToPlay.count
                self.setMusicToPlay(fileName: self.musicsToPlay[self.index], index: self.index)
            } else {
                self.setMusicToPlay(fileName: self.musicsToPlay[self.index], index: self.index)
            }
            self.player.play()
        }
        
    }
    
    
    @IBAction func playOrPauseButton(_ sender: UIButton) {
        if !sender.isSelected {
            player.play()
            sender.isSelected = true
        } else {
            player.pause()
            sender.isSelected = false
        }
    }
    
    
    @IBAction func progressThumbPressed(_ sender: Any) {
        isDragSlider = true
    }
    
    @IBAction func changeProgressSlider(_ sender: UISlider) {
        
        updateTime = CMTime(value: Int64(sender.value), timescale: 1)
        currentTimeLabel.text = formatedTime(updateTime.seconds)
        
    }
    
    @IBAction func progreeThumbNotPressed(_ sender: Any) {
        player.seek(to: updateTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
                  // Code you want to be delayed
                   self.isDragSlider = false
               }
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        index = (index + 1) % musicsToPlay.count
        setMusicToPlay(fileName: musicsToPlay[index], index: index)
        playButton.isSelected = true
        player.play()
    }
    
    @IBAction func previousButton(_ sender: Any) {
        index = (index + musicsToPlay.count - 1) % musicsToPlay.count
        setMusicToPlay(fileName: musicsToPlay[index], index: index)
        playButton.isSelected = true
        player.play()
        
    }
    
    @IBAction func randomMusicButton(_ sender: Any) {
        index = Int.random(in: 0...musicsToPlay.count - 1)
        setMusicToPlay(fileName: musicsToPlay[index], index: index)
    }
    @IBAction func loopMusicButton(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
        } else {
            sender.isSelected = false
        }
    }
    
    @IBAction func volumnChangeSlider(_ sender: UISlider) {
        player.volume = sender.value
    }

}

