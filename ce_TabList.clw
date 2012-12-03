! http://ClarionEdge.com

      Member()
         omit('***$***',_VER_C55)
_ABCDllMode_  EQUATE(0)
_ABCLinkMode_ EQUATE(1)
         ***$***
      Include('Equates.CLW'),ONCE
      Include('Keycodes.CLW'),ONCE
      Include('Errors.CLW'),ONCE
      Map
      End ! map
      Include('ce_TabList.inc'),ONCE
ce_TabList.Init     PROCEDURE  (WindowManager pWM, SIGNED pSheetFeq, <SIGNED pBoxFeq>, <SIGNED pImageFeq>, BYTE pSkipChecksAndOptions=FALSE) ! Declare Procedure
savePixels                   BYTE
  CODE
  savePixels     = 0{PROP:Pixels}
  0{PROP:Pixels} = TRUE

  SELF.sheetFeq = pSheetFeq
  IF SELF.sheetFeq{PROP:Left} = FALSE OR SELF.sheetFeq{PROP:LeftOffSet} = 0
    Message('ce_TabList.Init||' & |
            'Developer note: You need to design the window with the TABs on the left.|' & |
            '                AND set the width of the tabs manually!')
  END

  pWM.AddItem(SELF.WindowComponent)

  SELF.boxFeq = Create(0, CREATE:box)
  SELF.backgroundImageFeq = Create(0, CREATE:image)
  SELF.backgroundImageFeq{PROP:Text} = TABLIST_HEADER_IMAGE

  SELF.listFeq = Create(0, CREATE:list)
  IF SELF.listFeq = 0
    Stop('ce_TabList.Init - Error creating list control!')
  END

  SELF.listFeq{PROP:Xpos}   = SELF.sheetFeq{PROP:Xpos}
  SELF.listFeq{PROP:Ypos}   = SELF.sheetFeq{PROP:Ypos}
  SELF.listFeq{PROP:Width}  = SELF.sheetFeq{PROP:LeftOffSet} - (TABLIST_SEPERATION/2)
  SELF.listFeq{PROP:Height} = SELF.sheetFeq{PROP:Height} 

  SELF.sheetFeq{PROP:Xpos}   = SELF.sheetFeq{PROP:Xpos} + (TABLIST_SEPERATION/2)
  SELF.sheetFeq{PROP:Width}  = SELF.sheetFeq{PROP:Width} - TABLIST_SEPERATION
  SELF.sheetFeq{PROP:Wizard} = TRUE
  SELF.sheetFeq{PROP:Trn}    = TRUE

  ! Setup list style properties
  SELF.listFeq{PROP:Flat}          = TRUE
  SELF.listFeq{PROP:Hide}          = FALSE
  SELF.listFeq{PROP:Tip}           = '.' ! <-- required to make cell tips work!!
  SELF.listFeq{PROP:LineHeight}    = SELF.listFeq{PROP:LineHeight} + 6
  SELF.listFeq{PROPLIST:Underline} = TRUE
  SELF.listFeq{PROPLIST:Grid}      = COLOR:SCROLLBAR
  SELF.listFeq{PROPLIST:CellStyle, 1} = TRUE
  SELF.listFeq{PROPLIST:Tip, 1} = TRUE
  SELF.listFeq{PROPLIST:DefaultTip, 1} = ''
  SELF.listFeq{PROPLIST:TextSelected, 1} = COLOR:Black
  SELF.listFeq{PROPLIST:BackSelected, 1} = 03F9FFEh
  SELF.listFeq{PROPLIST:LeftOffset, 1} = 2
  SELF.listFeq{PROPSTYLE:FontStyle, 1} = FONT:bold
  SELF.listFeq{PROPSTYLE:FontStyle, 2} = FONT:bold+FONT:italic
  SELF.listFeq{PROPSTYLE:TextSelected, 2} = COLOR:Black
  SELF.listFeq{PROPSTYLE:BackSelected, 2} = 03F9FFEh

  !IF Omitted(pBoxFeq) = FALSE AND Omitted(pImageFeq) = FALSE
  !  SELF.boxFeq             = pBoxFeq
  !  SELF.backgroundImageFeq = pImageFeq
    SELF.SetupNoSheet(pSkipChecksAndOptions)
  !END

  0{PROP:Alrt,255} = CtrlTab
  0{PROP:Alrt,255} = CtrlShiftTab
  0{PROP:Pixels} = savePixels

  SELF.SetListFrom()
ce_TabList.SetListFrom PROCEDURE                          ! Declare Procedure
i                            LONG
tabFeq                       SIGNED
  CODE
  IF SELF.tabQ &= NULL
    SELF.tabQ &= New(tabQ_Type)
    Assert(~SELF.tabQ &= NULL,'Instantiating SELF.tabQ in ce_TabList.SetListFrom()')
  ELSE
    Free(SELF.tabQ)
  END

  LOOP
    i += 1
    tabFeq = SELF.sheetFeq{PROP:Child, i}
    IF tabFeq = 0
      BREAK
    END
    IF tabFeq{PROP:Hide} = TRUE
      CYCLE
    END
    
    SELF.tabQ.name = SELF.Replace(tabFeq{PROP:Text}, '&', '')

    SELF.tabQ.cellStyle = 1
    SELF.tabQ.cellTooltip = tabFeq{PROP:Tip}
    Add(SELF.tabQ)

    SELF.lastTabFeq = tabFeq
  END
  SELF.listFeq{PROP:From} = SELF.tabQ
ce_TabList.WindowComponent.TakeEvent PROCEDURE  () !,BYTE ! Declare Procedure
rv BYTE
  CODE
  rv = PARENT.WindowComponent.TakeEvent()

  CASE Event()
  OF EVENT:PreAlertKey
    ! Move focus to the list control
    Select(SELF.listFeq)
    IF KeyCode() = CtrlTab
      IF SELF.sheetFeq{PROP:ChoiceFEQ} = SELF.lastTabFeq
        ! This is to "wrap" the selection around the list
        SELF.listFeq{PROP:SelStart} = 1
        Post(EVENT:NewSelection, SELF.listFeq)
      ELSE
        PressKey(DownKey)
      END
    ELSIF KeyCode() = CtrlShiftTab
      IF SELF.sheetFeq{PROP:ChoiceFEQ} = SELF.sheetFeq{PROP:Child, 1}
        ! This is to "wrap" the selection around the list
        SELF.listFeq{PROP:SelStart} = Records(SELF.tabQ)
        Post(EVENT:NewSelection, SELF.listFeq)
      ELSE
        PressKey(UpKey)
      END
    END
  OF EVENT:NewSelection
    IF Field() = SELF.listFeq
      ! Change the style of the selected cell
      ! Reset last choice
      Get(SELF.tabQ, SELF.lastChoice)
      SELF.tabQ.cellStyle = 1
      Put(SELF.tabQ)
      ! Set new choice
      Get(SELF.tabQ, Choice(SELF.listFeq))
      SELF.tabQ.cellStyle = 2
      Put(SELF.tabQ)
      SELF.lastChoice = Choice(SELF.listFeq)

      SELF.sheetFeq{PROP:SelStart} = Choice(SELF.listFeq)
      Post(EVENT:NewSelection, SELF.sheetFeq)
    END
    SELF.TakeNewSelection()
  OF EVENT:OpenWindow
    SELF.listFeq{PROP:SelStart} = 1
    Post(EVENT:NewSelection, SELF.listFeq)
  OF EVENT:Accepted
    SELF.TakeAccepted()
  END

  RETURN rv
ce_TabList.SetupNoSheet PROCEDURE  (BYTE pSkipChecksAndOptions=FALSE) ! Declare Procedure
thisFeq                      SIGNED
tempFeq                      SIGNED
originalDisplayState         BYTE
  CODE
  SELF.sheetFeq{PROP:NoSheet} = TRUE

  SetPosition(SELF.boxFeq, |
              SELF.sheetFeq{PROP:Xpos}+SELF.sheetFeq{PROP:LeftOffSet} + TABLIST_SEPERATION, |
              SELF.sheetFeq{PROP:Ypos}, |
              SELF.sheetFeq{PROP:Width}-SELF.sheetFeq{PROP:LeftOffSet} - TABLIST_SEPERATION, |
              SELF.sheetFeq{PROP:Height})
  SELF.boxFeq{PROP:Color} = COLOR:WINDOWFRAME
  SELF.boxFeq{PROP:Fill}  = COLOR:WINDOW
  SELF.boxFeq{PROP:Hide}  = FALSE

  SetPosition(SELF.backgroundImageFeq, |
              SELF.boxFeq{PROP:Xpos}+2, |
              SELF.boxFeq{PROP:Ypos}+1, |
              SELF.boxFeq{PROP:Width}-4, |
              71)
  SELF.backgroundImageFeq{PROP:Hide} = FALSE

  ! Set all prompts checkboxes and groups and radio controls to transparent so they look pretty on top of our background image
  LOOP
    thisFeq = 0{PROP:NextField, thisFeq}
    IF thisFeq = 0
      BREAK
    END
    IF thisFeq < 0
      CYCLE
    END
    IF InList(thisFeq{PROP:Type}, |
              CREATE:prompt, |
              CREATE:option, |
              CREATE:check, |
              CREATE:radio, |
              CREATE:sstring, |
              CREATE:string) > 0 AND |
       (thisFeq{PROP:Background} = -1 OR thisFeq{PROP:Background} = 0)

      IF pSkipChecksAndOptions=TRUE AND |
         InList(thisFeq{PROP:Type}, |
               CREATE:option, |
               CREATE:check, |
               CREATE:radio) > 0
        ! Skip these ones though. PROP:Trn is ugly with SkinFramework applied!
        CYCLE
      END
      thisFeq{PROP:Trn} = TRUE
    END
  END
ce_TabList.Destruct PROCEDURE                             ! Declare Procedure
  CODE
  IF NOT SELF.tabQ &= NULL
    DISPOSE(SELF.tabQ)
  END
ce_TabList.Replace                PROCEDURE (STRING pFrom, STRING pFind, STRING pReplace) !,STRING
! FindString , ReplaceWith
locate                       LONG,AUTO
lastLocate                   LONG
  CODE
  ! Note: This is hacked out of a much larger dynamic string class
  !       In this implementation it is _assumed_ that the returned string will always be smaller than the pFrom string. Dirty, nasty hacky coding.
  !       Maybe later I will include the full dynamic string class. For now... this is enough for a demo (I use the full classes in production!)

  LOOP
    locate = InString(Upper(pFind), Upper(pFrom), 1, lastLocate+1)
    IF ~locate
      BREAK
    END

    ! So we dont end up having recursive replacement.
    lastLocate = locate + Len(pReplace)-1

    pFrom = Sub(pFrom, 1, locate-1)                  & |
             pReplace                                      & |
             Sub(pFrom , locate+Len(pFind), Len(pFrom))
  END

  RETURN pFrom

ce_TabList.TakeAccepted   PROCEDURE() !,VIRTUAL
  CODE

ce_TabList.TakeNewSelection   PROCEDURE () !,VIRTUAL
  CODE