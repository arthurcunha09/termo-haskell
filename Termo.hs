module Main where

import Data.Char (isAsciiUpper, isSpace, toUpper)
import Data.Time.Clock.POSIX (getPOSIXTime)

type Palavra = String

data Status = Correta | Deslocada | Ausente
  deriving (Eq, Show)

data Jogo = Jogo
  { segredo   :: Palavra
  , restantes :: Int
  , palpites  :: [[Status]] -- mais recente primeiro
  }

data Resultado = Venceu | Perdeu | Continua

-- Primeiro marca as letras na posicao certa; as deslocadas usam so as
-- letras do segredo que sobraram, para tratar letras repetidas.
avaliar :: Palavra -> Palavra -> [Status]
avaliar seg palpite = marcar sobras (zip palpite exatas)
  where
    exatas = zipWith (==) seg palpite
    sobras = map fst (filter (not . snd) (zip seg exatas))

marcar :: String -> [(Char, Bool)] -> [Status]
marcar _ [] = []
marcar disp ((_, True) : resto) = Correta : marcar disp resto
marcar disp ((c, False) : resto)
  | c `elem` disp = Deslocada : marcar (remover c disp) resto
  | otherwise     = Ausente : marcar disp resto

remover :: Eq a => a -> [a] -> [a]
remover _ [] = []
remover x (y : ys)
  | x == y    = ys
  | otherwise = y : remover x ys

validar :: [Palavra] -> String -> Either String Palavra
validar aceitas texto
  | not (all isAsciiUpper p) = Left "Use apenas letras, sem acento."
  | length p /= 5            = Left "A palavra deve ter 5 letras."
  | p `notElem` aceitas      = Left "Palavra nao encontrada na lista."
  | otherwise                = Right p
  where
    p = map toUpper (filter (not . isSpace) texto)

resultado :: Jogo -> Resultado
resultado (Jogo _ _ (ultimo : _))
  | all (== Correta) ultimo = Venceu
resultado (Jogo _ 0 _) = Perdeu
resultado _            = Continua

mostrar :: Palavra -> [Status] -> String
mostrar p ss = concat (zipWith pintar p ss)
  where
    pintar c s = cor s ++ " " ++ [c] ++ " \ESC[0m"
    cor Correta   = "\ESC[30;42m"
    cor Deslocada = "\ESC[30;43m"
    cor Ausente   = "\ESC[97;100m"

main :: IO ()
main = do
  aceitas  <- fmap lines (readFile "aceitas.txt")
  secretas <- fmap lines (readFile "secretas.txt")
  t <- getPOSIXTime
  let seg = secretas !! (floor (t * 1000) `mod` length secretas)
  putStrLn "Adivinhe a palavra de 5 letras em 6 tentativas."
  laco aceitas (Jogo seg 6 [])

laco :: [Palavra] -> Jogo -> IO ()
laco aceitas jogo =
  case resultado jogo of
    Venceu   -> putStrLn "Parabens, voce acertou!"
    Perdeu   -> putStrLn ("A palavra era " ++ segredo jogo ++ ".")
    Continua -> do
      putStrLn ("Tentativa " ++ show (7 - restantes jogo) ++ " de 6:")
      texto <- getLine
      case validar aceitas texto of
        Left erro -> do
          putStrLn erro
          laco aceitas jogo
        Right p -> do
          let ss = avaliar (segredo jogo) p
          putStrLn (mostrar p ss)
          laco aceitas (Jogo (segredo jogo) (restantes jogo - 1) (ss : palpites jogo))
