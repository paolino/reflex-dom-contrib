{-# LANGUAGE CPP                      #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE JavaScriptFFI            #-}

{-|

API for dealing with keyboard events.

-}

module Reflex.Dom.Contrib.KeyEvent
  ( KeyEvent(..)
  , key
  , shift
  , ctrlKey
  , Reflex.Dom.Contrib.KeyEvent.getKeyEvent
  ) where

------------------------------------------------------------------------------
import           Control.Monad.Reader
import           Data.Char
import           GHCJS.DOM.EventM (event)
import           GHCJS.DOM.Types hiding (Event)
import           GHCJS.Types
import           Reflex.Dom
------------------------------------------------------------------------------


------------------------------------------------------------------------------
#ifdef ghcjs_HOST_OS

foreign import javascript unsafe "$1.ctrlKey"
  js_uiEventGetCtrlKey :: JSRef UIEvent -> IO Bool

foreign import javascript unsafe "$1.shiftKey"
  js_uiEventGetShiftKey :: JSRef UIEvent -> IO Bool

#else

js_uiEventGetCtrlKey :: JSRef UIEvent -> IO Bool
js_uiEventGetCtrlKey = error "js_uiEventGetCtrlKey only works in GHCJS."

js_uiEventGetShiftKey :: JSRef UIEvent -> IO Bool
js_uiEventGetShiftKey = error "js_uiEventGetShiftKey only works in GHCJS."

#endif


------------------------------------------------------------------------------
-- | Data structure with the details of key events.
data KeyEvent = KeyEvent
   { keKeyCode :: Int
   , keCtrl :: Bool
   , keShift :: Bool
   } deriving (Show, Read, Eq, Ord)


------------------------------------------------------------------------------
-- | Convenience constructor for KeyEvent with no modifiers pressed.
key :: Char -> KeyEvent
key k = KeyEvent
   { keKeyCode = ord k
   , keCtrl = False
   , keShift = False
   }


------------------------------------------------------------------------------
-- | Set the shift modifier of a KeyEvent.
shift :: KeyEvent -> KeyEvent
shift ke = ke { keShift = True }


------------------------------------------------------------------------------
-- | Set the ctrl modifier of a KeyEvent.
ctrlKey :: Char -> KeyEvent
ctrlKey k = (key $ toUpper k) { keCtrl = True }


------------------------------------------------------------------------------
getKeyEvent :: ReaderT (t, UIEvent) IO KeyEvent
getKeyEvent = do
  e <- event
  code <- Reflex.Dom.getKeyEvent
  liftIO $ KeyEvent <$> pure code
                    <*> js_uiEventGetCtrlKey (unUIEvent e)
                    <*> js_uiEventGetShiftKey (unUIEvent e)

