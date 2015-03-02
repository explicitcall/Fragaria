//
//  MGSTemporaryPreferencesObserver.m
//  Fragaria
//
//  Created by Jim Derry on 2/27/15.
//
//

#import "MGSTemporaryPreferencesObserver.h"
#import "MGSFragaria.h"


// KVO context constants
char kcAutoSomethingChanged;
char kcBackgroundColorChanged;
char kcColoursChanged;
char kcFragariaInvisibleCharactersColourWellChanged;
char kcFragariaTabWidthChanged;
char kcFragariaTextFontChanged;
char kcInsertionPointColorChanged;
char kcGutterGutterTextColourWell;
char kcGutterWidthPrefChanged;
char kcInvisibleCharacterValueChanged;
char kcLineHighlightingChanged;
char kcLineNumberPrefChanged;
char kcLineWrapPrefChanged;
char kcMultiLineChanged;
char kcPageGuideChanged;
char kcSyntaxColourPrefChanged;
char kcTextColorChanged;
char kcShowMatchingBracesChanged;
char kcAutoInsertionPrefsChanged;
char kcIndentingPrefsChanged;


@interface MGSTemporaryPreferencesObserver ()

@property (nonatomic, weak) MGSFragaria *fragaria;

@end


@implementation MGSTemporaryPreferencesObserver {
    NSMutableArray *registeredKeyPaths;
}

/*
 *  - initWithFragaria:
 */
- (instancetype)initWithFragaria:(MGSFragaria *)fragaria
{
    if ((self = [super init]))
    {
        self.fragaria = fragaria;
        registeredKeyPaths = [[NSMutableArray alloc] init];
        [self registerKVO];
    }
	
    return self;
}


/*
 * - dealloc
 */
-(void)dealloc
{
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *keyPath;
    
    for (keyPath in registeredKeyPaths) {
        [defaultsController removeObserver:self forKeyPath:keyPath];
    }
}


- (void)observeDefault:(NSString*)prop context:(void*)ctxt
{
    [self observeDefaults:@[prop] context:ctxt];
}


- (void)observeDefaults:(NSArray*)arry context:(void*)ctxt
{
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *keyPath;
    NSUInteger i;
    NSKeyValueObservingOptions opts;
    
    i = 1;
    for (NSString *prop in arry) {
        keyPath = [NSString stringWithFormat:@"values.%@", prop];
        
        opts = (i == [arry count]) ? NSKeyValueObservingOptionInitial : 0;
        [defaultsController addObserver:self forKeyPath:keyPath options:opts context:ctxt];
        [registeredKeyPaths addObject:keyPath];
        i++;
    }
}


/*
 *  - registerKVO
 */
-(void)registerKVO
{
    // SMLTextView
    [self observeDefault:MGSFragariaPrefsGutterWidth context:&kcGutterWidthPrefChanged];
    [self observeDefault:MGSFragariaPrefsSyntaxColourNewDocuments context:&kcSyntaxColourPrefChanged];
    [self observeDefault:MGSFragariaPrefsShowLineNumberGutter context:&kcLineNumberPrefChanged];
    [self observeDefault:MGSFragariaPrefsLineWrapNewDocuments context:&kcLineWrapPrefChanged];
    [self observeDefault:MGSFragariaPrefsGutterTextColourWell context:&kcGutterGutterTextColourWell];
    [self observeDefault:MGSFragariaPrefsTextFont context:&kcFragariaTextFontChanged];
    [self observeDefault:MGSFragariaPrefsInvisibleCharactersColourWell context:&kcFragariaInvisibleCharactersColourWellChanged];
    [self observeDefault:MGSFragariaPrefsShowInvisibleCharacters context:&kcInvisibleCharacterValueChanged];
    [self observeDefault:MGSFragariaPrefsTabWidth context:&kcFragariaTabWidthChanged];
    [self observeDefault:MGSFragariaPrefsBackgroundColourWell context:&kcBackgroundColorChanged];
    [self observeDefault:MGSFragariaPrefsGutterTextColourWell context:&kcInsertionPointColorChanged];
    [self observeDefault:MGSFragariaPrefsGutterTextColourWell context:&kcTextColorChanged];
    
    [self observeDefaults:@[MGSFragariaPrefsShowPageGuide, MGSFragariaPrefsShowPageGuideAtColumn] context:&kcPageGuideChanged];
    
    [self observeDefaults:@[MGSFragariaPrefsAutoSpellCheck, MGSFragariaPrefsAutomaticLinkDetection, MGSFragariaPrefsAutoGrammarCheck, MGSFragariaPrefsSmartInsertDelete] context:&kcAutoSomethingChanged];
    
    [self observeDefaults:@[MGSFragariaPrefsHighlightCurrentLine, MGSFragariaPrefsHighlightLineColourWell] context:&kcLineHighlightingChanged];
    
    [self observeDefault:MGSFragariaPrefsShowMatchingBraces context:&kcShowMatchingBracesChanged];
    
    [self observeDefaults:@[MGSFragariaPrefsAutoInsertAClosingBrace, MGSFragariaPrefsAutoInsertAClosingParenthesis] context:&kcAutoInsertionPrefsChanged];
    
    [self observeDefaults:@[MGSFragariaPrefsIndentWithSpaces, MGSFragariaPrefsUseTabStops, MGSFragariaPrefsIndentNewLinesAutomatically, MGSFragariaPrefsAutomaticallyIndentBraces] context:&kcIndentingPrefsChanged];

	// SMLSyntaxColouring
	[self observeDefaults:@[
      MGSFragariaPrefsCommandsColourWell,     MGSFragariaPrefsCommentsColourWell,
      MGSFragariaPrefsInstructionsColourWell, MGSFragariaPrefsKeywordsColourWell,
      MGSFragariaPrefsAutocompleteColourWell, MGSFragariaPrefsVariablesColourWell,
      MGSFragariaPrefsStringsColourWell,      MGSFragariaPrefsAttributesColourWell,
      MGSFragariaPrefsNumbersColourWell,
	  MGSFragariaPrefsColourCommands,     MGSFragariaPrefsColourComments,
      MGSFragariaPrefsColourInstructions, MGSFragariaPrefsColourKeywords,
      MGSFragariaPrefsColourAutocomplete, MGSFragariaPrefsColourVariables,
      MGSFragariaPrefsColourStrings,      MGSFragariaPrefsColourAttributes,
      MGSFragariaPrefsColourNumbers] context:&kcColoursChanged];
	
	[self observeDefaults:@[MGSFragariaPrefsColourMultiLineStrings, MGSFragariaPrefsOnlyColourTillTheEndOfLine] context:&kcMultiLineChanged];
}


/*
 *  - observerValueForKeyPath:ofObject:change:context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL boolValue;
    NSColor *colorValue;
    NSFont *fontValue;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (context == &kcGutterWidthPrefChanged)
    {
        self.fragaria.gutterMinimumWidth = [defaults integerForKey:MGSFragariaPrefsGutterWidth];
    }
    else if (context == &kcLineNumberPrefChanged)
    {
        boolValue = [defaults boolForKey:MGSFragariaPrefsShowLineNumberGutter];
        self.fragaria.showsGutter = boolValue;
    }
    else if (context == &kcSyntaxColourPrefChanged)
    {
        boolValue = [defaults boolForKey:MGSFragariaPrefsSyntaxColourNewDocuments];
        self.fragaria.isSyntaxColoured = boolValue;
    }
    else if (context == &kcLineWrapPrefChanged)
    {
        boolValue = [defaults boolForKey:MGSFragariaPrefsLineWrapNewDocuments];
        self.fragaria.lineWrap = boolValue;
    }
    else if (context == &kcGutterGutterTextColourWell)
    {
        self.fragaria.gutterTextColour = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsGutterTextColourWell]];
    }
    else if (context == &kcInvisibleCharacterValueChanged)
    {
        self.fragaria.showsInvisibleCharacters = [defaults boolForKey:MGSFragariaPrefsShowInvisibleCharacters];
    }
    else if (context == &kcFragariaTextFontChanged)
    {
        fontValue = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsTextFont]];
        self.fragaria.textFont = fontValue;   // these won't always be tied together, but this is current behavior.
        self.fragaria.gutterFont = fontValue; // these won't always be tied together, but this is current behavior.
    }
    else if (context == &kcFragariaInvisibleCharactersColourWellChanged)
    {
        self.fragaria.textInvisibleCharactersColour = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsInvisibleCharactersColourWell]];
    }
    else if (context == &kcFragariaTabWidthChanged)
    {
        self.fragaria.tabWidth = [defaults integerForKey:MGSFragariaPrefsTabWidth];
    }
    else if (context == &kcAutoSomethingChanged)
    {
        self.fragaria.continuousSpellCheckingEnabled = [defaults integerForKey:MGSFragariaPrefsAutoSpellCheck];
        self.fragaria.grammarCheckingEnabled = [defaults integerForKey:MGSFragariaPrefsAutoGrammarCheck];
        self.fragaria.smartInsertDeleteEnabled = [defaults integerForKey:MGSFragariaPrefsSmartInsertDelete];
    }
    else if (context == &kcShowMatchingBracesChanged)
    {
        self.fragaria.showsMatchingBraces = [defaults boolForKey:MGSFragariaPrefsShowMatchingBraces];
    }
    else if (context == &kcAutoInsertionPrefsChanged)
    {
        self.fragaria.insertClosingBraceAutomatically = [defaults boolForKey:MGSFragariaPrefsAutoInsertAClosingBrace];
        self.fragaria.insertClosingParenthesisAutomatically = [defaults boolForKey:MGSFragariaPrefsAutoInsertAClosingParenthesis];
    }
    else if (context == &kcIndentingPrefsChanged)
    {
        self.fragaria.indentWithSpaces = [defaults boolForKey:MGSFragariaPrefsIndentWithSpaces];
        self.fragaria.useTabStops = [defaults boolForKey:MGSFragariaPrefsUseTabStops] ;
        self.fragaria.indentNewLinesAutomatically = [defaults boolForKey:MGSFragariaPrefsIndentNewLinesAutomatically];
        self.fragaria.indentBracesAutomatically = [defaults boolForKey:MGSFragariaPrefsAutomaticallyIndentBraces];
    }
    else if (context == &kcBackgroundColorChanged)
    {
        self.fragaria.textView.backgroundColor = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsBackgroundColourWell]];
    }
    else if (context == &kcInsertionPointColorChanged || context == &kcTextColorChanged)
    {
        colorValue = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsTextColourWell]];
        self.fragaria.textView.insertionPointColor = colorValue;
        self.fragaria.textView.textColor = colorValue;
    }
    else if (context == &kcPageGuideChanged)
    {
        self.fragaria.pageGuideColumn = [defaults integerForKey:MGSFragariaPrefsShowPageGuideAtColumn];
        self.fragaria.showsPageGuide = [defaults boolForKey:MGSFragariaPrefsShowPageGuide];
    }
    else if (context == &kcLineHighlightingChanged)
    {
        self.fragaria.highlightsCurrentLine = [defaults boolForKey:MGSFragariaPrefsHighlightCurrentLine];
        self.fragaria.currentLineHighlightColour = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsHighlightLineColourWell]];
    }
    else if (context == &kcMultiLineChanged)
    {
        self.fragaria.colourMultiLineStringsEnabled = [defaults boolForKey:MGSFragariaPrefsColourMultiLineStrings];
        self.fragaria.colourOnlyUntilEndOfLineEnabled = [defaults boolForKey:MGSFragariaPrefsOnlyColourTillTheEndOfLine];
    }
    else if (context == &kcColoursChanged)
    {
        self.fragaria.coloursAttributes = [defaults boolForKey:MGSFragariaPrefsColourAttributes];
        self.fragaria.coloursAutocomplete = [defaults boolForKey:MGSFragariaPrefsColourAutocomplete];
        self.fragaria.coloursCommands = [defaults boolForKey:MGSFragariaPrefsColourCommands];
        self.fragaria.coloursComments = [defaults boolForKey:MGSFragariaPrefsColourComments];
        self.fragaria.coloursInstructions = [defaults boolForKey:MGSFragariaPrefsColourInstructions];
        self.fragaria.coloursKeywords = [defaults boolForKey:MGSFragariaPrefsColourKeywords];
        self.fragaria.coloursNumbers = [defaults boolForKey:MGSFragariaPrefsColourNumbers];
        self.fragaria.coloursStrings = [defaults boolForKey:MGSFragariaPrefsColourStrings];
        self.fragaria.coloursVariables = [defaults boolForKey:MGSFragariaPrefsColourVariables];
        self.fragaria.colourForAttributes = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsAttributesColourWell]];
        self.fragaria.colourForAutocomplete = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsAutocompleteColourWell]];
        self.fragaria.colourForCommands = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsCommandsColourWell]];
        self.fragaria.colourForComments = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsCommentsColourWell]];
        self.fragaria.colourForInstructions = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsInstructionsColourWell]];
        self.fragaria.colourForKeywords = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsKeywordsColourWell]];
        self.fragaria.colourForNumbers = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsNumbersColourWell]];
        self.fragaria.colourForStrings = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsStringsColourWell]];
        self.fragaria.colourForVariables = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:MGSFragariaPrefsVariablesColourWell]];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
