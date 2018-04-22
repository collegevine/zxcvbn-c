{-# OPTIONS_GHC -fno-warn-tabs #-}

import Distribution.Simple
import Distribution.Simple.Setup
import System.Process

main = defaultMainWithHooks simpleUserHooks
	{ preConf = buildCLib
	, preClean = cleanCLib
	}

buildCLib _ _ = do
	system "make dict-src.h"
	return (Nothing, [])

cleanCLib _ _ = do
	system "make clean"
	system "rm -f dict-src.h" -- clean misses this file
	return (Nothing, [])
	
