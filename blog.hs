{-# LANGUAGE OverloadedStrings #-}

import Hakyll

main :: IO ()
main =
  hakyll $ do
    match "images/*" $ do
      route idRoute
      compile copyFileCompiler
    match "css/*" $ do
      route idRoute
      compile compressCssCompiler
    match (fromList ["about.md", "contact.md"]) $ do
      route $ setExtension "html"
      compile $
        pandocCompiler >>=
        loadAndApplyTemplate "templates/default.html" defaultContext >>=
        relativizeUrls
    match "posts/*" $ do
      route $ setExtension "html"
      compile $
        pandocCompiler >>= loadAndApplyTemplate "templates/post.html" postCtx >>=
        saveSnapshot "content" >>=
        loadAndApplyTemplate "templates/default.html" postCtx >>=
        relativizeUrls
    match "index.html" $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*"
        let indexCtx =
              listField "posts" postCtx (return posts) <> defaultContext
        getResourceBody >>= applyAsTemplate indexCtx >>=
          loadAndApplyTemplate "templates/default.html" indexCtx >>=
          relativizeUrls
    match "templates/*" $ compile templateBodyCompiler
    create ["feed.xml"] $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAllSnapshots "posts/*" "content"
        renderRss
          FeedConfiguration
            { feedTitle = "Shao Cheng's Blog"
            , feedDescription = "Shao Cheng's Blog"
            , feedAuthorName = "Shao Cheng"
            , feedAuthorEmail = "YXN0cm9oYXZvY0BnbWFpbC5jb20="
            , feedRoot = "https://terrorjack.com"
            }
          (postCtx <> bodyField "description")
          posts

postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" <> defaultContext
