import TurtleLexer
import TurtleParser
import System.Environment
import System.IO

main :: IO ()
main = do
  (filename : _) <- getArgs
  text <- readFile filename
  let tree = parseTurtle $ alexScanTokens text
  print tree
