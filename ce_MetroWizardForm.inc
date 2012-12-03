! http://ClarionEdge.com
_ce_MetroWizardForm_ EQUATE(1)

  PRAGMA('project(#pragma link(resources\header_ce_metro_24x24.ico))')
  PRAGMA('project(#pragma link(resources\cancel_ce_metro_24x24.ico))')
  PRAGMA('project(#pragma link(resources\navigation-right_ce_metro_24x24.ico))')
  PRAGMA('project(#pragma link(resources\navigation-left_ce_metro_24x24.ico))')
  PRAGMA('project(#pragma link(resources\thumb_up_ce_metro_24x24.ico))')

  include('ce_TabList.inc'),ONCE
  include('ABWINDOW.INC'),ONCE
!--------------------------------------------------------------------------------
!Class ce_MetroWizardForm
!
!--------------------------------------------------------------------------------
ce_MetroWizardForm          Class(ce_TabList),Type,Module('ce_MetroWizardForm.Clw'),LINK('ce_MetroWizardForm.Clw',1)
! Properties
lightColor                    LONG
darkColor                     LONG
fontColor                     LONG
fontSelectedColor             LONG

headerHeight                  LONG
footerHeight                  LONG
headerImage                   CSTRING(255)
listTitleFontSize             LONG
headerFontSize                LONG
footerFontSize                LONG

headerImageFeq                SIGNED
boxHeaderFeq                  SIGNED
boxFooterFeq                  SIGNED
boxListTitleFeq               SIGNED
promptListTitleFeq            SIGNED
promptHeaderFeq               SIGNED
promptFooterFeq               SIGNED
regionListBorderFeq           SIGNED
promptTabHeader               SIGNED
promptTabDetail               SIGNED
buttonClose                   SIGNED
buttonCloseIcon                   CSTRING(255)
buttonOK                      SIGNED
buttonOKIcon                      CSTRING(255)
buttonNext                    SIGNED
buttonNextIcon                    CSTRING(255)
buttonPrevious                SIGNED
buttonPreviousIcon                CSTRING(255)

! Methods
Init                          PROCEDURE(WindowManager pWM, SIGNED pSheetFeq) ,VIRTUAL 
MoveOriginalControls          PROCEDURE(),VIRTUAL
CreateControls                PROCEDURE(),VIRTUAL
SetupWindow                   PROCEDURE(),VIRTUAL
SetupButtons                  PROCEDURE(),VIRTUAL
SetButtonStyle                PROCEDURE(SIGNED pFeq, STRING pIcon) ,VIRTUAL
SetHeaderIcon                 PROCEDURE(STRING pText)
SetHeaderText                 PROCEDURE(STRING pText)
SetListHeaderText             PROCEDURE(STRING pText)
SetFooterText                 PROCEDURE(STRING pText)
Construct                     PROCEDURE
TakeAccepted                  PROCEDURE,DERIVED
TakeNewSelection              PROCEDURE,DERIVED
                     END
!_EndOfInclude_