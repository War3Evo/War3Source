
//#define MAX_SOUND_FILES 5000
#define STOCK_SOUND 1

/**
 * @section Bitwise values definitions for admin flags.
 */
#define PRIORITY_TOP			(1<<0)		/**< Convenience macro for Admin_Reservation as a FlagBit */
#define PRIORITY_HIGH			(1<<1)		/**< Convenience macro for Admin_Generic as a FlagBit */ //%50
#define PRIORITY_MEDIUM			(1<<2)		/**< Convenience macro for Admin_Kick as a FlagBit */    //%25
#define PRIORITY_LOW			(1<<3)		/**< Convenience macro for Admin_Ban as a FlagBit */ //%
#define PRIORITY_BOTTOM			(1<<4)		/**< Convenience macro for Admin_Unban as a FlagBit */
//#define PRIORITY_				(1<<5)		/**< Convenience macro for Admin_Slay as a FlagBit */
//#define PRIORITY_			(1<<6)		/**< Convenience macro for Admin_Changemap as a FlagBit */
//#define PRIORITY_				(1<<7)		/**< Convenience macro for Admin_Convars as a FlagBit */
//#define PRIORITY_				(1<<8)		/**< Convenience macro for Admin_Config as a FlagBit */
//#define PRIORITY_				(1<<9)		/**< Convenience macro for Admin_Chat as a FlagBit */
//#define PRIORITY_				(1<<10)		/**< Convenience macro for Admin_Vote as a FlagBit */
//#define PRIORITY_			(1<<11)		/**< Convenience macro for Admin_Password as a FlagBit */
//#define PRIORITY_				(1<<12)		/**< Convenience macro for Admin_RCON as a FlagBit */
//#define PRIORITY_				(1<<13)		/**< Convenience macro for Admin_Cheats as a FlagBit */
//#define PRIORITY_				(1<<14)		/**< Convenience macro for Admin_Root as a FlagBit */
//#define PRIORITY_				(1<<15)		/**< Convenience macro for Admin_Custom1 as a FlagBit */
//#define PRIORITY_				(1<<16)		/**< Convenience macro for Admin_Custom2 as a FlagBit */
//#define PRIORITY_				(1<<17)		/**< Convenience macro for Admin_Custom3 as a FlagBit */
//#define PRIORITY_				(1<<18)		/**< Convenience macro for Admin_Custom4 as a FlagBit */
//#define PRIORITY_				(1<<19)		/**< Convenience macro for Admin_Custom5 as a FlagBit */
#define PRIORITY_TAKE_FORWARD				(1<<20)		/**< Convenience macro for Admin_Custom6 as a FlagBit */

/**
 * Adds Sounds to DownloadTable and Cache as needed. 
 * 
 * @param soundfile: Sound file to cache
 * @param priority: Uses forward priority when called

 * @return nothing
 */
native War3_AddSound(String:soundfile[],stocksound=0,priority=PRIORITY_TAKE_FORWARD);

// WARD EVENTS

forward OnAddSound(sound_priority);

