module TestHacl where

import Universum

import Control.Concurrent (threadDelay)
import qualified Data.Time.Clock.POSIX as P
import System.Random (randomRIO)

import Hacl
import qualified Lib as L
import Playground

testBNs :: IO ()
testBNs = do
    let bitl = 1024
    n <- genPrime bitl
    let bn = fromIntegral $ length $ inbase b64 n
    a <- randomRIO (0,n`div`2)
    b <- randomRIO (0,n`div`2)
    putTextLn $ "n: " <> show n
    putTextLn $ "a: " <> show a
    putTextLn $ "a2: " <> show (a*a)
    putTextLn $ "b: " <> show b
    putTextLn $ "(a+b) mod n: " <> show (a+b)
    putTextLn $ "a^b mod n: " <> show (L.exp n a b)

    bnN <- toBignum bn n
    bnA <- toBignum bn a
    bnB <- toBignum bn b
    res <- toBignum bn 0

    bnModExp bn bn bnN bnA bnB res
    expRes <- fromBignum bn res

    putTextLn $ "expRes: " <> show expRes
    print $ expRes == (L.exp n a b)


benchBNs :: IO ()
benchBNs = do
    let bitl = 1024
    n <- genPrime bitl
    let bn0 = fromIntegral $ length $ inbase b64 n
    let bn = bn0 + 1

    a <- randomRIO (0,n-1)
    b <- randomRIO (0,n-1)
    c <- randomRIO (0,a-1)

    s1 <- randomRIO (0,2^(bitl`div`3))
    s2 <- randomRIO (0,2^(bitl`div`3))

    bnN <- toBignum bn n
    bnA <- toBignum bn a
    bnB <- toBignum bn b
    bnC <- toBignum bn c
    res <- toBignum bn 0
    bnS1 <- toBignum bn s1
    bnS2 <- toBignum bn s2

    time0 <- P.getPOSIXTime

    replicateM_ 10000 $ bnRemainder bn bn bnA bnC res

    time1 <- P.getPOSIXTime

    replicateM_ 10000 $ bnModAdd bn bnN bnA bnB res

    time2 <- P.getPOSIXTime

    replicateM_ 10000 $ bnModMul bn bnN bnA bnB res

    time3 <- P.getPOSIXTime

    replicateM_ 10000 $ bnMulFitting bn bn bn bnS1 bnS2 res

    time4 <- P.getPOSIXTime

    replicateM_ 10000 $ bnModExp bn bn bnN bnA bnB res

    time5 <- P.getPOSIXTime

    putTextLn $ "Mod: " <> show ((time1 - time0) / 10000)
    putTextLn $ "Add: " <> show ((time2 - time1) / 10000)
    putTextLn $ "Mul: " <> show ((time3 - time2) / 10000)
    putTextLn $ "MulFit: " <> show ((time3 - time2) / 10000)
    putTextLn $ "Exp(ssl): " <> show ((time5 - time4) / 10000)


testGM :: Int -> IO ()
testGM bits = do
    putTextLn "Testing GM"
    let test = do
          (p,q,y,r,m1,m2) <- genDataGM bits
          let n = p * q

          let bN = fromIntegral $ length $ inbase b64 n

          n' <- toBignum bN n
          p' <- toBignum bN p
          y' <- toBignum bN y
          r' <- toBignum bN r
          pmin1 <- toBignum bN (p-1)
          pmin1half <- toBignum bN ((p-1)`div`2)

          c1 <- toBignum bN 0
          c2 <- toBignum bN 0
          c3 <- toBignum bN 0


          time1 <- P.getPOSIXTime

          replicateM_ 99 $ gmEnc bN n' y' r' m1 c1
          gmEnc bN n' y' r' m2 c2

          time2 <- P.getPOSIXTime

          replicateM_ 99 $ gmDec bN p' pmin1 pmin1half c1
          m1' <- gmDec bN p' pmin1 pmin1half c1

          time3 <- P.getPOSIXTime

          replicateM_ 100 $ gmXor bN n' c1 c2 c3

          time4 <- P.getPOSIXTime


          when (m1 /= m1') $ error $ "GM failed: " <> show (p,q,y,r,m1,m2)
          pure ( (time2 - time1) / 100
               , (time3 - time2) / 100
               , (time4 - time3) / 100)

    let tries = 10
    timings <- replicateM tries test

    let average xs = foldr1 (+) xs / fromIntegral tries
    let avg1 = average $ map (view _1) timings
    let avg2 = average $ map (view _2) timings
    let avg3 = average $ map (view _3) timings

    putTextLn $ "Enc: " <> show (avg1 * 1000) <> " ms"
    putTextLn $ "Dec: " <> show (avg2 * 1000) <> " ms"
    putTextLn $ "Xor: " <> show (avg3 * 1000) <> " ms"


testPaillier :: Int -> IO ()
testPaillier bits = do
    putTextLn "Testing paillier"
    let test = do
          (p,q,r,m1,m2) <- genDataPaillier bits
          let n = p * q
          let n2 = n * n

          let bN = fromIntegral $ length $ inbase b64 n2

          p' <- toBignum bN p
          q' <- toBignum bN q
          n' <- toBignum bN n
          n2' <- toBignum bN n2
          g' <- toBignum bN (n + 1)
          r' <- toBignum bN r
          m1' <- toBignum bN m1
          m2' <- toBignum bN m2
          lambda' <- toBignum bN 0
          l2inv' <- toBignum bN 0

          paillierToSec bN p' q' n' n2' g' lambda' l2inv'

          c1 <- toBignum bN 0
          c2 <- toBignum bN 0
          c3 <- toBignum bN 0
          d <- toBignum bN 0

          time1 <- P.getPOSIXTime

          replicateM_ 99 $ paillierEnc bN n' n2' g' r' m1' c1
          paillierEnc bN n' n2' g' r' m2' c2

          time2 <- P.getPOSIXTime

          replicateM_ 100 $ paillierDec bN p' q' n' n2' g' lambda' l2inv' c1 d

          time3 <- P.getPOSIXTime

          replicateM_ 100 $ paillierHomAdd bN n' n2' c1 c2 c3

          time4 <- P.getPOSIXTime

          replicateM_ 100 $ paillierHomMulScal bN n' n2' c1 m2' c3

          time5 <- P.getPOSIXTime


          m'' <- fromBignum bN d
          when (m1 /= m'') $ error $ "Paillier failed: " <> show (p,q,r,m1)

          pure ( (time2 - time1) / 100
               , (time3 - time2) / 100
               , (time4 - time3) / 100
               , (time5 - time4) / 100)

    let tries = 100
    timings <- replicateM tries test

    let average xs = foldr1 (+) xs / fromIntegral tries
    let avg1 = average $ map (view _1) timings
    let avg2 = average $ map (view _2) timings
    let avg3 = average $ map (view _3) timings
    let avg4 = average $ map (view _4) timings

    putTextLn $ "Enc: " <> show (avg1 * 1000) <> " ms"
    putTextLn $ "Dec: " <> show (avg2 * 1000) <> " ms"
    putTextLn $ "Hom_add: " <> show (avg3 * 1000) <> " ms"
    putTextLn $ "Hom_mul_scal: " <> show (avg4 * 1000) <> " ms"

testPaillierPahe :: IO ()
testPaillierPahe = do
    putTextLn "Testing paillier PAHE"

    let n = 5
    let l::Integer = 8
    sk <- paheKeyGen @PailSep n (2^l)
    let pk = paheToPublic sk

    ms1 <- replicateM n $ randomRIO (0, 2^l)
    ms2 <- replicateM n $ randomRIO (0, 2^l)

    c1 <- paheEnc pk ms1
    c2 <- paheEnc pk ms2
    c3 <- paheSIMDAdd pk c1 c2
    d <- paheDec sk c3

    print $ d == map (uncurry (+)) (zip ms1 ms2)



testDGK :: IO ()
testDGK = do
    putTextLn "Testing DGK"

    -- genDataDGKWithPrimes 2 (2^20) 700
    let (uprimes,p,q,u,v,g,h) =
          ([1048583,1048589],1895089596695635987044392085844392979345094436303371616593800702072823833377343780663139692699220309214467,1233650831883099230153849542876191261913580924454571036409560025644937233018208400997158133586030949795059,1099532599387,1426476897108638371825766716642800048506732913643,1656538870108677916077033972037100235170746303410383531631175515688417525915790037496147585782798401746528225873757261702451073191397227907472359036081702994394585493896112852303850272946094029353544515902429963,1109134116557813645666153083598642098863534434376690627045137653790218908038050002143975865840590196552485698017229738578393420525943325790374596246808527264216261339249706287872874469197014263981049460345253999)
    --params@(uprimes,p,q,u,v,g,h) <- genDataDGKWithPrimes 2 (2^20) 700
    --print params
    let ufact = map (,1) uprimes
    unless (L.exp (p*q) h v == 1) $ error "generated params are broken"
    unless (L.exp (p*q) g (u*v) == 1) $ error "generated params are broken"
    let n = p * q
    let bN = fromIntegral $ length $ inbase b64 n

    putTextLn "Params generated!"


    p' <- toBignum bN p
    q' <- toBignum bN q
    n' <- toBignum bN n
    u' <- toBignum bN u
    g' <- toBignum bN g
    h' <- toBignum bN h
    u_ps <- toBignumList bN $ map fst ufact
    u_es <- toBignumList bN $ map snd ufact
    v' <- toBignum bN v

    let test = do
          m1 <- randomRIO (0,u-1)
          m2 <- randomRIO (0,u-1)
          r <- randomRIO (0,n-1)

          r' <- toBignum bN r
          m1' <- toBignum bN m1
          m2' <- toBignum bN m2

          c1 <- toBignum bN 0
          c2 <- toBignum bN 0
          c3 <- toBignum bN 0
          c4 <- toBignum bN 0
          d <- toBignum bN 0

          let decrypt ciph =
                  dgkDec bN (fromIntegral $ length ufact)
                    p' q' n' u' u_ps u_es v' g' h' ciph d

          time1 <- P.getPOSIXTime

          replicateM_ 999 $ dgkEnc bN n' u' g' h' r' m1' c1
          dgkEnc bN n' u' g' h' r' m2' c2

          time2 <- P.getPOSIXTime

          replicateM_ 1000 $ decrypt c1

          time3 <- P.getPOSIXTime

          replicateM_ 1000 $ dgkHomAdd bN n' c1 c2 c3

          time4 <- P.getPOSIXTime

          replicateM_ 1000 $ dgkHomMulScal bN n' c1 m2' c4

          time5 <- P.getPOSIXTime

          c'' <- fromBignum bN c1
          unless (c'' == (L.exp n g m1 * L.exp n h r) `mod` n) $
              error "encryption is broken"

          m'' <- fromBignum bN d
          when (m1 /= m'') $ error $ "DGK failed: " <> show (p,q,r,m1, m'')

          decrypt c3
          m3 <- fromBignum bN d
          when (m3 /= (m1 + m2) `mod` u) $ error "DGK hom add failed"

          decrypt c4
          m4 <- fromBignum bN d
          when (m4 /= (m1 * m2) `mod` u) $ error "DGK hom mul failed"

          pure ( (time2 - time1) / 1000
               , (time3 - time2) / 1000
               , (time4 - time3) / 1000
               , (time5 - time4) / 1000
               )

    let tries = 5

    timings <- replicateM tries test

    let average xs = foldr1 (+) xs / fromIntegral tries
    let avg1 = average $ map (view _1) timings
    let avg2 = average $ map (view _2) timings
    let avg3 = average $ map (view _3) timings
    let avg4 = average $ map (view _4) timings

    putTextLn $ "Enc: "          <> show (avg1 * 1000) <> " ms"
    putTextLn $ "Dec: "          <> show (avg2 * 1000) <> " ms"
    putTextLn $ "Hom_add: "      <> show (avg3 * 1000) <> " ms"
    putTextLn $ "Hom_mul_scal: " <> show (avg4 * 1000) <> " ms"