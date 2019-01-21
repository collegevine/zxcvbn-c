{-# LANGUAGE ForeignFunctionInterface #-}

module Text.Password.Strength (Password, UserDict, Entropy, estimate) where

#include <zxcvbn.h>

import Foreign
import Foreign.C
import System.IO.Unsafe

type Password = String

-- | Entropy estimation in bits.
type Entropy = Double

-- | List of words that would be particularly bad in the password,
-- to suppliment the built-in word lists.
-- The name of the user is a good candidate to include here.
type UserDict = [String]

#ifdef mingw32_HOST_OS

estimate :: Password -> UserDict -> Entropy
estimate _ _ = 0

#else

foreign import ccall unsafe "zxcvbn.h ZxcvbnMatch" zxcvbnMatch 
	:: CString
	-- ^ password
	-> Ptr CString
	-- ^ array of user dictionary words
	-> Ptr ()
	-- ^ used to get information about parts of the password,
	-- but this binding does not implement that, so a null pointer
	-> IO CDouble

estimate :: Password -> UserDict -> Entropy
estimate pw ud = unsafePerformIO $
	withCString pw $ \c_pw ->
		convud [] ud $ \c_udl -> 
			withArray0 nullPtr c_udl $ \c_ud -> do
				ent <- zxcvbnMatch c_pw c_ud nullPtr
				return $ fromRational $ toRational ent
  where
	convud cs [] a = a cs
	convud cs (x:xs) a = withCString x $ \c_x ->
		convud (c_x : cs) xs a

#endif
