#pragma once
#include <limits>
#include <type_traits>

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
 * @param min_val Minimum value of the range.
 * @param max_val Maximum value of the range.
 * @param len Length to be scaled according the value and range.
 * @param clip Determines if the length needs to be clipped withing the set
 * range.
 * @return Resulted scaled value.
 */
template<class T, class S>
auto calculateOffset(T value, T min_val, T max_val, S len, bool clip) -> S
{
	max_val -= min_val;
	value -= min_val;
	S temp;
	if constexpr (std::is_floating_point<T>())
	{
		temp = len * (value / max_val);
	}
	else
	{
		temp = (len * value) / max_val;
	}
	temp = (max_val && value) ? temp : 0;
	// Clip when required.
	if (clip)
	{
		// When the len is a negative value.
		if (len < 0)
		{
			return (temp < len)
				? len
				: (temp > S(0))
				? S(0)
				: temp;
		}
		return (temp > len)
			? len
			: (temp < S(0))
			? S(0)
			: temp;
	}
	return temp;
}

/**
 * @brief Returns clipped value of v between a and b where a < b.
 * @tparam T Type of the values
 * @param value Value needing to be clipped,
 * @param min_val Begin value of the range.
 * @param max_val End value of the range.
 * @return Clipped value.
 */
template<class T>
inline auto clip(const T value, const T min_val, const T max_val) -> T
{
	return (value < min_val)
		? min_val
		: (
				(value > max_val)
					? max_val
					: value
			);
}

}// namespace MySpace