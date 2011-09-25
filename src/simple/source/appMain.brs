' ********************************************************************
' **  Andy's Hardcoded Video Play
' **  Copyright (c) 2009 Roku Inc. All Rights Reserved.
' ********************************************************************

Sub Main()
    'initialize theme attributes like titles, logos and overhang color
    initTheme()

    'prepare the screen for display and get ready to begin
    screen=preShowPosterScreen("", "")
    if screen=invalid then
        print "unexpected error in preShowPosterScreen"
        return
    end if
 
    'set to go, time to get started
    showPosterScreen(screen)
 
End Sub

'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'*************************************************************
Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangPrimaryLogoOffsetSD_X = "72"
    theme.OverhangPrimaryLogoOffsetSD_Y = "15"
    theme.OverhangSliceSD = "pkg:/images/Overhang_BackgroundSlice_SD43.png"
    theme.OverhangPrimaryLogoSD  = "pkg:/images/Logo_Overhang_SD43.png"

    theme.OverhangPrimaryLogoOffsetHD_X = "123"
    theme.OverhangPrimaryLogoOffsetHD_Y = "20"
    theme.OverhangSliceHD = "pkg:/images/Overhang_BackgroundSlice_HD.png"
    theme.OverhangPrimaryLogoHD  = "pkg:/images/Logo_Overhang_HD.png"
    
    app.SetTheme(theme)

End Sub

'******************************************************
'** Perform any startup/initialization stuff prior to 
'** initially showing the screen.  
'******************************************************
Function preShowPosterScreen(breadA=invalid, breadB=invalid) As Object
    port=CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if
    screen.SetListStyle("flat-category")
    return screen
End Function

'******************************************************
'** Display the poster screen and wait for events from 
'** the screen. The screen will show retreiving while
'** we fetch and parse the feeds for the show posters
'******************************************************
Function showPosterScreen(screen As Object) As Integer

    categoryList = getCategoryList()
    screen.SetListNames(categoryList)
    screen.SetContentList(getShowsForCategoryItem(categoryList[0]))
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            print "showPosterScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListFocused() then
                'get the list of shows for the currently selected item
                screen.SetContentList(getShowsForCategoryItem(categoryList[msg.GetIndex()]))
                print "list focused | current category = "; msg.GetIndex()
            else if msg.isListItemFocused() then
                print"list item focused | current show = "; msg.GetIndex()
            else if msg.isListItemSelected() then
                print "list item selected | current show = "; msg.GetIndex() 
                'if you had a list of shows, the index of the current item 
                'is probably the right show, so you'd do something like this
                'm.curShow = displayShowDetailScreen(showList[msg.GetIndex()])
                showSpringboardScreen(msg)
            else if msg.isScreenClosed() then
                return -1
            end if
        end If
    end while


End Function

Sub showChoices()
    screen = CreateObject("roPosterScreen")
    screen.SetBreadcrumbText("", "breadcrumb")
    
    screen.Show()
    content = []
    content.Push({
                SDPosterUrl: "pkg:/images/MainMenu_Icon_Side_SD43.png"
                HDPosterUrl: "pkg:/images/MainMenu_Icon_Side_HD.png"
                ShortDescriptionLine1: "Something contentish"
            })
    screen.SetContentList(content)

    
    'showSpringboardScreen(itemVenter)
End Sub




'*************************************************************
'** showSpringboardScreen()
'*************************************************************

Function showSpringboardScreen(msg as object) As Boolean
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")

    print "showSpringboardScreen on ";msg
    
    screen.SetMessagePort(port)
    screen.AllowUpdates(false)
    
    item = { ContentType:"episode"
               SDPosterUrl:"file://pkg:/images/CraigVenter-2008.jpg"
               HDPosterUrl:"file://pkg:/images/CraigVenter-2008.jpg"
               IsHD:False
               HDBranded:False
               ShortDescriptionLine1:"Some hard-coded text here."
               ShortDescriptionLine2:""
               Description:"More descriptions here."
               Rating:"NR"
               StarRating:"80"
               Length:1972
               Categories:["Technology","Talk"]
               Title:"Craig Venter asks, Can we create new life out of our digital universe?"
               }
               
    if item <> invalid and type(item) = "roAssociativeArray"
        screen.SetContent(item)
    endif

    screen.SetDescriptionStyle("generic") 'audio, movie, video, generic
                                        ' generic+episode=4x3,
    screen.ClearButtons()
    screen.AddButton(1,"Play")
    screen.AddButton(2,"Go Back")
    screen.SetStaticRatingEnabled(false)
    screen.AllowUpdates(true)
    screen.Show()

    downKey=3
    selectKey=6
    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roSpringboardScreenEvent"
            if msg.isScreenClosed()
                print "Screen closed"
                exit while                
            else if msg.isButtonPressed()
                    print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                    if msg.GetIndex() = 1
                         displayVideo("")
                    else if msg.GetIndex() = 2
                         return true
                    endif
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        else 
            print "wrong type.... type=";msg.GetType(); " msg: "; msg.GetMessage()
        endif
    end while


    return true
End Function


'*************************************************************
'** displayVideo()
'*************************************************************

Function displayVideo(args As Dynamic)
    print "Displaying video: "
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)

    'bitrates  = [0]          ' 0 = no dots, adaptive bitrate
    'bitrates  = [348]    ' <500 Kbps = 1 dot
    'bitrates  = [664]    ' <800 Kbps = 2 dots
    'bitrates  = [996]    ' <1.1Mbps  = 3 dots
    'bitrates  = [2048]    ' >=1.1Mbps = 4 dots
    bitrates  = [0]    

    'Swap the commented values below to play different video clips...
    urls = ["http://192.168.0.3/videos/DAMAGES_SEASON_3_DISC_1-1.m4v"]
    qualities = ["SD"]
    StreamFormat = "mp4"
    title = "Damages, Episode 3-1"
    srt = ""

    'urls = ["http://video.ted.com/talks/podcast/DanGilbert_2004_480.mp4"]
    'qualities = ["HD"]
    'StreamFormat = "mp4"
    'title = "Dan Gilbert asks, Why are we happy?"

    ' Apple's HLS test stream
    'urls = ["http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"]
    'qualities = ["SD"]
    'streamformat = "hls"
    'title = "Apple BipBop Test Stream"

    ' Big Buck Bunny test stream from Wowza
    'urls = ["http://ec2-174-129-153-104.compute-1.amazonaws.com:1935/vod/smil:BigBuckBunny.smil/playlist.m3u8"]
    'qualities = ["SD"]
    'streamformat = "hls"
    'title = "Big Buck Bunny"

    if type(args) = "roAssociativeArray"
        if type(args.url) = "roString" and args.url <> "" then
            urls[0] = args.url
        end if
        if type(args.StreamFormat) = "roString" and args.StreamFormat <> "" then
            StreamFormat = args.StreamFormat
        end if
        if type(args.title) = "roString" and args.title <> "" then
            title = args.title
        else 
            title = ""
        end if
        if type(args.srt) = "roString" and args.srt <> "" then
            srt = args.StreamFormat
        else 
            srt = ""
        end if
    end if
    
    videoclip = CreateObject("roAssociativeArray")
    videoclip.StreamBitrates = bitrates
    videoclip.StreamUrls = urls
    videoclip.StreamQualities = qualities
    videoclip.StreamFormat = StreamFormat
    videoclip.Title = title
    print "srt = ";srt
    if srt <> invalid and srt <> "" then
        videoclip.SubtitleUrl = srt
    end if
    
    video.SetContent(videoclip)
    video.show()

    lastSavedPos   = 0
    statusInterval = 10 'position must change by more than this number of seconds before saving

    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then 'ScreenClosed event
                print "Closing video screen"
                exit while
            else if msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()
                if nowpos > 10000
                    
                end if
                if nowpos > 0
                    if abs(nowpos - lastSavedPos) > statusInterval
                        lastSavedPos = nowpos
                    end if
                end if
            else if msg.isRequestFailed()
                print "play failed: "; msg.GetMessage()
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        end if
    end while
End Function


Function displayBase64()
    ba = CreateObject("roByteArray")
    str = "Aladdin:open sesame"
    ba.FromAsciiString(str)
    result = ba.ToBase64String() 
    print result

    ba2 = CreateObject("roByteArray")
    ba2.FromBase64String(result)
    result2 = ba2.ToAsciiString()
    print result2
End Function

'**********************************************************
'** When a poster on the home screen is selected, we call
'** this function passing an roAssociativeArray with the 
'** ContentMetaData for the selected show.  This data should 
'** be sufficient for the springboard to display
'**********************************************************
Function displayShowDetailScreen(category as Object, showIndex as Integer) As Integer

    'add code to create springboard, for now we do nothing
    return 1

End Function


'**************************************************************
'** Return the list of categories to display in the filter
'** banner. The result is an roArray containing the names of 
'** all of the categories. All just static data for the example.
'***************************************************************
Function getCategoryList() As Object

    categoryList = CreateObject("roArray", 10, true)

    categoryList = [ "Comedy", "Drama", "News", "Reality", "Daytime"  ]
    return categoryList

End Function


'********************************************************************
'** Given the category from the filter banner, return an array 
'** of ContentMetaData objects (roAssociativeArray's) representing 
'** the shows for the category. For this example, we just cheat and
'** create and return a static array with just the minimal items
'** set, but ideally, you'd go to a feed service, fetch and parse
'** this data dynamically, so content for each category is dynamic
'********************************************************************
Function getShowsForCategoryItem(category As Object) As Object

    print "getting shows for category "; category

    showList = [
        {
            ShortDescriptionLine1:"Show #1",
            ShortDescriptionLine2:"Short Description for Show #1",
        }
        {
            ShortDescriptionLine1:"Show #2",
            ShortDescriptionLine2:"Short Description for Show #2",
            HDPosterUrl:"pkg:/media/bogusFileName_hd.jpg",
            SDPosterUrl:"pkg:/media/bogusFileName_hd.jpg"
        }
        {
            ShortDescriptionLine1:"Show #3",
            ShortDescriptionLine2:"Short Description for Show #3",
        }
    ]

    return showList

End Function

