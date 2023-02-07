#pragma once
/**
 * Just a file and namespace to demonstrate the Doxygen manual generation.
 *
 * [Go to the Main page](@ref main)
 */
namespace MySpace
{

/**
 * @brief Calculates the offset for a given range and set point.
 * @tparam T Type of the passed arguments for scaling.
 * @tparam S The type of the to be scaled argument.
 * @param value Value in the range.
 * @param min Minimum value of the range.
 * @param max Maximum value of the range.
 * @param len Length to be scaled according the value and range.
 * @param clip Determines if the length needs to be clipped withing the set range.
 * @return Resulted scaled value.
 */
template<class T, class S>
inline
S calculateOffset(T value, T min, T max, S len, bool clip)
{
	max -= min;
	value -= min;
	S temp = (max && value) ? (std::numeric_limits<T>::is_iec559 ? len * (value / max) : (len * value) / max) : 0;
	// Clip when required.
	if (clip)
	{
		// When the len is a negative value.
		if (len < 0)
		{
			return ((temp < len) ? len : (temp > S(0)) ? S(0) : temp);
		}
		else
		{
			return ((temp > len) ? len : (temp < S(0)) ? S(0) : temp);
		}
	}
	return temp;
}

/**
 * @brief Returns clipped value of v between a and b where a < b.
 * @tparam T Type of the values
 * @param v Value needing to be clipped,
 * @param a Begin value of the range.
 * @param b End value of the range.
 * @return Clipped value.
 */
template<class T>
T clip(const T v, const T a, const T b)
{
	return (v < a) ? a : ((v > b) ? b : v);
}

}